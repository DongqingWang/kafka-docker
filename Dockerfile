FROM openjdk:8-jre-alpine
MAINTAINER Dongqing

ARG kafka_version=2.1.1
ARG scala_version=2.12
ARG glibc_version=2.27-r0

RUN apk add --no-cache \
    bash \
    curl \
    jq

ENV KAFKA_USER=kafka \
    KAFKA_VERSION=$kafka_version \
    SCALA_VERSION=$scala_version \
    KAFKA_HOME=/kafka \
    KAFKA_DATA_DIR=/var/kafka/data \
    GLIBC_VERSION=$glibc_version


ENV PATH=${PATH}:${KAFKA_HOME}/bin

COPY download.sh KEYS /


RUN set -ex; \
    adduser -D "$KAFKA_USER"; \
    apk add --no-cache --virtual .build-deps \
        ca-certificates \
        gnupg \
        libressl; \
    cd /; \
    chmod +x /download.sh; \
    /download.sh; \
    ls -l "/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"; \
    gpg --import KEYS; \
    gpg --verify "kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz.asc" "kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"; \
    tar -xzf "kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"; \
    rm -rf "kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" "kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz.asc" /download.sh; \
    apk del .build-deps

COPY log4j.properties /kafka_${SCALA_VERSION}-${KAFKA_VERSION}/config/

RUN set -ex; \
    ln -s /kafka_${SCALA_VERSION}-${KAFKA_VERSION} $KAFKA_HOME; \
    mkdir -p $KAFKA_DATA_DIR; \
    chown -R "$KAFKA_USER:$KAFKA_USER" /kafka_${SCALA_VERSION}-${KAFKA_VERSION}; \
    chown -R "$KAFKA_USER:$KAFKA_USER"  $KAFKA_DATA_DIR
