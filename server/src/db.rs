use anyhow::{anyhow, Result};
use rand::{distributions::Alphanumeric, thread_rng, Rng};
use rusqlite::params;
use std::path::Path;

pub type Pool = r2d2::Pool<r2d2_sqlite::SqliteConnectionManager>;

pub fn initialize<P: AsRef<Path>>(path: P) -> Result<Pool> {
    let manager = r2d2_sqlite::SqliteConnectionManager::file(path);
    let pool = Pool::new(manager).map_err(|e| anyhow!("Failed to open database pool: {:?}", e))?;

    pool.get()?.execute(
        "create table if not exists user_names (id integer not null primary key autoincrement, names text not null, secret text not null)",
        [],
    )?;

    Ok(pool)
}

pub fn create_new_user(pool: &Pool) -> Result<(u32, String)> {
    let conn = pool
        .get()
        .map_err(|e| anyhow!("Failed to get pooled connection: {:?}", e))?;

    let secret: String = thread_rng()
        .sample_iter(&Alphanumeric)
        .take(24)
        .map(char::from)
        .collect();

    conn.execute(
        "insert into user_names(names, secret) values('[]', ?)",
        params![secret],
    )
    .map_err(|e| anyhow!("Failed to create new user record: {:?}", e))?;
    let id = conn.last_insert_rowid();

    Ok((id as u32, secret))
}

pub fn get_user_names(pool: &Pool, id: u32) -> Result<Vec<String>> {
    let conn = pool
        .get()
        .map_err(|e| anyhow!("Failed to get pooled connection: {:?}", e))?;

    let names: String = conn
        .query_row(
            "select names from user_names where id=?",
            params![id],
            |row| row.get(0),
        )
        .map_err(|e| anyhow!("Failed to get names for id `{}`: {:?}", id, e))?;

    let names: Vec<String> = serde_json::from_str(&names)
        .map_err(|e| anyhow!("Failed to parse JSON name list for id `{}`: {:?}", id, e))?;

    Ok(names)
}

pub fn set_user_names(pool: &Pool, id: u32, secret: &str, names: &Vec<String>) -> Result<()> {
    let mut conn = pool
        .get()
        .map_err(|e| anyhow!("Failed to get pooled connection: {:?}", e))?;

    let names: String = serde_json::to_string(names).map_err(|e| {
        anyhow!(
            "Failed to serialize names list `{:?}` into JSON: {:?}",
            names,
            e
        )
    })?;

    // use a transaction so that in case the query doesn't change any rows (i.e. an invalid
    // secret / id combo was used), we can roll any changes that may have inadvertently
    // happened back
    let t = conn
        .transaction()
        .map_err(|e| anyhow!("failed to start update transaction: {:?}", e))?;
    let affected_rows = t
        .execute(
            "update user_names set names=? where id=? and secret=?",
            params![names, id, secret],
        )
        .map_err(|e| {
            anyhow!(
                "Failed to update user names for id {} with names `{:?}`: {:?}",
                id,
                names,
                e
            )
        })?;

    if affected_rows != 1 {
        t.rollback()
            .map_err(|e| anyhow!("failed to rollback update transaction: {:?}", e))?;
        Err(anyhow!(
            "Failed to update user names for id {}: no rows changed",
            id
        ))
    } else {
        t.commit()
            .map_err(|e| anyhow!("failed to commit update transaction: {:?}", e))?;
        Ok(())
    }
}
