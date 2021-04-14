# Nom de Bébé Server

A very simple server to enable users to share baby name lists in the main app.

## Deployment

### Environment variables

| Variable  | Description                                 | Default              |
|:----------|:--------------------------------------------|:---------------------|
| `ADDR`    | Server binding point, in `ip:port` notation | `127.0.0.1:8080`     |
| `SALT`    | Salt for encoding / decoding user IDs       | **Must be provided** |
| `PADDING` | Minimum length of encoded user IDs          | `12`                 |
| `DBPATH`  | The path to the database file to use        | `nomdebebe.db`†      |

† Note: If the (SQLite3) database file doesn't exist, it will be created and initialized.

## Executable

This is just a fairly standard [Rust](https://www.rust-lang.org/) program. Build using stable or latest nightly:

```bash
cargo build --release
```

And the executable will be at `./target/release/nomdebebe-server`. If the database file

## Docker

For convenience, a docker image is available: [`hamaluik/nomdebebe-server`](https://hub.docker.com/repository/docker/hamaluik/nomdebebe-server).

### Running

1. Create a volume for the database:
```bash
docker volume create nomdebebe-server-database
```
2. Start the container:
```bash
docker run \
  --detach \
  --name nomdebebe-server \
  --restart=unless-stopped \
  --publish "8080:8080" \
  --mount "source=nomdebebe-server-database,target=/data" \
  --env "ADDR=0.0.0.0:8080" \
  --env "SALT=Kosher" \
  --env "PADDING=12" \
  --env "DBPATH=/data/nomdebebe.db" \
  hamaluik/nomdebebe-server:latest
```

