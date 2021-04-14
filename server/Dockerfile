FROM rust:1 AS build
WORKDIR /usr/src

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y build-essential pkg-config

RUN USER=root cargo new nomdebebe-server
WORKDIR /usr/src/nomdebebe-server
COPY Cargo.toml Cargo.lock ./
COPY src ./src
RUN cargo install --path .

FROM debian:buster-slim
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y libsqlite3-0
COPY --from=build /usr/local/cargo/bin/nomdebebe-server .
#USER 1000
CMD ["./nomdebebe-server"]

