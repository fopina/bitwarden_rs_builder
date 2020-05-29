#!/bin/sh

if [ -z "$1" ]; then
    echo "Usage: $0 [VERSION]"
    echo "Valid versions are the ones available in https://hub.docker.com/r/bitwardenrs/server/tags"
    echo "(if there is a tag 1.14.2-whatever, 1.14.2 is the version)"
    exit 2
fi

set -e

VERSION=$(echo $1 | cut -d '-' -f1)
PATCH=$(echo $1 | cut -d '-' -f2)
TAG=$1

cd $(dirname $0)
mkdir -p bins

# alpine is amd64
for arch in alpine,amd64 armv6,arm aarch64,arm64; do
    IFS=","
    set -- $arch
    docker pull bitwardenrs/server:${VERSION}-$1
    CONTID=$(docker create bitwardenrs/server:${VERSION}-$1)
    docker cp ${CONTID}:/bitwarden_rs bins/bitwarden_rs_$2
    docker rm ${CONTID}
done

CONTID=$(docker create bitwardenrs/server:${VERSION}-$1)
docker cp ${CONTID}:/web-vault bins/web-vault
docker rm ${CONTID}

docker buildx build \
            --platform linux/amd64,linux/arm64,linux/arm/v6 \
            --build-arg VERSION=${TAG} \
            -f Dockerfile \
            --push \
            -t fopina/bitwarden_rs:${TAG} \
            -t fopina/bitwarden_rs:latest \
            .
