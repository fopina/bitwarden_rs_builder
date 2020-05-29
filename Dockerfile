FROM alpine:3.11 as stripper

RUN apk add --no-cache binutils

ARG TARGETARCH
COPY bins/bitwarden_rs_${TARGETARCH} /bitwarden_rs
RUN strip /bitwarden_rs

# need static arm binaries for alpine...
FROM debian:buster-slim

RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    openssl \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /data
VOLUME /data

COPY bins/web-vault /web-vault
COPY --from=stripper /bitwarden_rs /bitwarden_rs

EXPOSE 8000

ENTRYPOINT [ "/bitwarden_rs" ]
