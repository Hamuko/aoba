# --------------- #
# BUILD CONTAINER #
# --------------- #

FROM rust:1.73 as build

ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

RUN USER=root cargo new --bin aoba

WORKDIR ./aoba
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml

RUN cargo build --release

RUN rm src/*.rs
RUN rm ./target/release/deps/aoba*

ADD . ./

RUN cargo build --release --verbose

# ----------------- #
# RUNTIME CONTAINER #
# ----------------- #

FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    pip3 install -U --break-system-packages gallery-dl && \
    pip3 install -U --break-system-packages youtube_dl && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1000 aoba && useradd -g aoba aoba

WORKDIR /home/aoba/bin/

COPY --from=build /aoba/target/release/aoba .
RUN chown aoba:aoba aoba

USER aoba

ENV ROCKET_ADDRESS=0.0.0.0
ENV GALLERY_DL_PATH=/gallery-dl
ENV YOUTUBE_DL_PATH=/youtube-dl

CMD ["./aoba"]
