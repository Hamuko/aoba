# --------------- #
# BUILD CONTAINER #
# --------------- #

FROM rust:1.57 as build

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

FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    pip3 install -U gallery-dl && \
    pip3 install -U youtube_dl

RUN groupadd -g 1000 aoba && useradd -g aoba aoba

WORKDIR /home/aoba/bin/

COPY --from=build /aoba/target/release/aoba .
RUN chown aoba:aoba aoba

USER aoba

ENV ROCKET_ADDRESS=0.0.0.0
ENV GALLERY_DL_PATH=/gallery-dl
ENV YOUTUBE_DL_PATH=/youtube-dl

CMD ["./aoba"]
