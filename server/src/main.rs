use actix_web::{get, post, web, App, HttpResponse, HttpServer};
use anyhow::{anyhow, Result};
use harsh::Harsh;
use once_cell::sync::OnceCell;
use serde::{Deserialize, Serialize};

mod db;
use db::Pool;

struct HarshConfig {
    salt: String,
    padding: usize,
}

static HARSH_CONFIG: OnceCell<HarshConfig> = OnceCell::new();

#[derive(Serialize)]
struct NewIdResp {
    id: String,
    secret: String,
}

#[get("/id/new")]
async fn new_id(
    harsh: web::Data<Harsh>,
    pool: web::Data<Pool>,
) -> Result<HttpResponse, HttpResponse> {
    let (id, secret) = db::create_new_user(&pool).map_err(|e| {
        log::error!("Failed to get next id: {}", e);
        HttpResponse::InternalServerError()
    })?;

    let id = harsh.encode(&[id as u64]);
    let resp = NewIdResp { id, secret };

    Ok(HttpResponse::Ok().json(resp))
}

#[get("/names/{id}")]
async fn get_names_for_id(
    web::Path(id): web::Path<String>,
    harsh: web::Data<Harsh>,
    pool: web::Data<Pool>,
) -> Result<HttpResponse, HttpResponse> {
    let id = match harsh.decode(&id) {
        Ok(ids) => {
            if ids.len() != 1 {
                log::warn!("harsh decoded `{}` into `{:?}` (not singular)", id, ids);
                return Err(HttpResponse::NotFound().finish());
            }
            *ids.first().unwrap()
        }
        Err(e) => {
            log::warn!("harsh decode error for id `{}`: {:?}", id, e);
            return Err(HttpResponse::NotFound().finish());
        }
    };

    let names = db::get_user_names(&pool, id as u32).map_err(|e| {
        log::error!("failed to get user names for user `{}`: {:?}", id, e);
        HttpResponse::NotFound()
    })?;

    Ok(HttpResponse::Ok().json(names))
}

#[derive(Deserialize)]
struct SecretQuery {
    secret: String,
}

#[post("/names/{id}")]
async fn set_names_for_id(
    web::Path(id): web::Path<String>,
    query: web::Query<SecretQuery>,
    names: web::Json<Vec<u32>>,
    harsh: web::Data<Harsh>,
    pool: web::Data<Pool>,
) -> Result<HttpResponse, HttpResponse> {
    let id = match harsh.decode(&id) {
        Ok(ids) => {
            if ids.len() != 1 {
                log::warn!("harsh decoded `{}` into `{:?}` (not singular)", id, ids);
                return Err(HttpResponse::NotFound().finish());
            }
            *ids.first().unwrap()
        }
        Err(e) => {
            log::warn!("harsh decode error for id `{}`: {:?}", id, e);
            return Err(HttpResponse::NotFound().finish());
        }
    };

    db::set_user_names(&pool, id as u32, &query.secret, &names).map_err(|e| {
        log::error!("failed to set user names for user `{}`: {:?}", id, e);
        HttpResponse::BadRequest()
    })?;

    Ok(HttpResponse::Ok().finish())
}

fn set_up_logging() {
    use fern::colors::{Color, ColoredLevelConfig};

    let colors_line = ColoredLevelConfig::new()
        .error(Color::Red)
        .warn(Color::Yellow)
        .info(Color::White)
        .debug(Color::White)
        .trace(Color::BrightBlack);

    let colors_level = colors_line.clone().info(Color::Green);
    fern::Dispatch::new()
        .format(move |out, message, record| {
            out.finish(format_args!(
                "{color_line}[{date}][{target}][{level}{color_line}] {message}\x1B[0m",
                color_line = format_args!(
                    "\x1B[{}m",
                    colors_line.get_color(&record.level()).to_fg_str()
                ),
                date = chrono::Local::now().to_rfc3339(),
                target = record.target(),
                level = colors_level.color(record.level()),
                message = message,
            ));
        })
        .level(log::LevelFilter::Info)
        .chain(std::io::stdout())
        .apply()
        .unwrap();
}
#[actix_web::main]
async fn main() -> Result<()> {
    set_up_logging();
    dotenv::dotenv().ok();

    // collect the address we want to bind to, falling back to port 8080 on localhost
    let addr = std::env::var("ADDR")
        .ok()
        .unwrap_or_else(|| "127.0.0.1:8080".to_owned());

    // use hash-ids to obfuscate the IDs
    // this isn't the most secure, but it should be fine for these purposes
    let salt = std::env::var("SALT").map_err(|_| anyhow!("Missing environment variable: SALT"))?;
    let padding = std::env::var("PADDING").unwrap_or_else(|_| "12".to_owned());
    let padding: usize = padding.parse().map_err(|e| {
        anyhow!(
            "Failed to parse PADDING (`{}`) as a positive integer: {}",
            padding,
            e
        )
    })?;

    // get the database path from env
    let db_path = std::env::var("DBPATH").unwrap_or_else(|_| "nomdebebe.db".to_owned());

    // initialize the database
    let pool = db::initialize(&db_path)?;

    log::info!("Launching server with config:");
    log::info!("ADDR = {}", addr);
    log::info!("SALT = {}", salt);
    log::info!("PADDING = {}", padding);
    log::info!("DBPATH = {}", db_path);

    // stick this in a global singleton as it doesn't change and actix
    // needs to access it from every responder thread
    let harsh_config = HarshConfig { salt, padding };
    HARSH_CONFIG
        .set(harsh_config)
        .map_err(|_| anyhow!("Failed to setup hash ID configuration"))?;

    // launch the server
    HttpServer::new(move || {
        App::new()
            // Use a data factory so that each API call isn't tripping over each other
            // to access the Harsh config. This creates a new Harsh config for each
            // thread, but hopefully that is less overhead than blocking on
            // each API call. I haven't tested it though, so this may have been a waste
            // of 20 minutes.
            .data_factory(|| async {
                let HarshConfig { salt, padding } = HARSH_CONFIG.get().unwrap();
                Ok::<harsh::Harsh, harsh::BuildError>(
                    harsh::HarshBuilder::new()
                        .salt(salt.to_owned())
                        .length(*padding)
                        .build()
                        .unwrap(),
                )
            })
            .data(pool.clone())
            .service(new_id)
            .service(get_names_for_id)
            .service(set_names_for_id)
    })
    .bind(addr)?
    .run()
    .await
    .map_err(|e| anyhow!("Actix error: {:?}", e))
}
