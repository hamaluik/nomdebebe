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
    names: web::Json<Vec<String>>,
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

#[actix_web::main]
async fn main() -> Result<()> {
    std::env::set_var("RUST_LOG", "actix_web=info");
    env_logger::init();
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

    // initialize the database
    let pool = db::initialize()?;

    log::info!("Launching server with config:");
    log::info!("ADDR = {}", addr);
    log::info!("SALT = {}", salt);
    log::info!("PADDING = {}", padding);

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
