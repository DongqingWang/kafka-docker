FROM openjdk:8-jre-alpine
MAINTAINER Dongqing

RUN apk add --no-cache \
    bash \
    su-exec \
    jq \
    curl

ENV ZOO_USER=zookeeper \
    ZOO_CONF_DIR=/conf \
    ZOO_DATA_DIR=/data \
    ZOO_DATA_LOG_DIR=/datalog \
    ZOO_LOG_DIR=/logs \
    ZOO_PORT=2181 \
    ZOO_TICK_TIME=2000 \
    ZOO_INIT_LIMIT=5 \
    ZOO_SYNC_LIMIT=2 \
    ZOO_AUTOPURGE_PURGEINTERVAL=0 \
    ZOO_AUTOPURGE_SNAPRETAINCOUNT=3 \
    ZOO_MAX_CLIENT_CNXNS=60

RUN set -ex; \
    adduser -D "$ZOO_USER"; \
    mkdir -p "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR" "$ZOO_LOG_DIR"; \
    chown "$ZOO_USER:$ZOO_USER" "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR" "$ZOO_LOG_DIR"

ARG GPG_KEY=C61B346552DC5E0CB53AA84F59147497767E7473
ARG DISTRO_NAME=zookeeper-3.4.13

COPY download.sh KEYS /

RUN set -ex; \
    apk add --no-cache --virtual .build-deps \
        ca-certificates \
        gnupg \
        libressl; \
    cd /; \
    chmod +x /download.sh; \
    /download.sh; \
    ls -l "/$DISTRO_NAME.tar.gz"; \
    gpg --import KEYS; \
    gpg --verify "$DISTRO_NAME.tar.gz.asc" "$DISTRO_NAME.tar.gz"; \
    tar -xzf "$DISTRO_NAME.tar.gz"; \
    mv "/$DISTRO_NAME/conf/"* "$ZOO_CONF_DIR"; \
    rm -rf "$GNUPGHOME" "$DISTRO_NAME.tar.gz" "$DISTRO_NAME.tar.gz.asc" /download.sh; \
    ln -s /$DISTRO_NAME /zookeeper; \
    rm -rf /zookeeper/CHANGES.txt \
    /zookeeper/README.txt \
    /zookeeper/NOTICE.txt \
    /zookeeper/CHANGES.txt \
    /zookeeper/README_packaging.txt \
    /zookeeper/build.xml \
    /zookeeper/config \
    /zookeeper/contrib \
    /zookeeper/dist-maven \
    /zookeeper/docs \
    /zookeeper/ivy.xml \
    /zookeeper/ivysettings.xml \
    /zookeeper/recipes \
    /zookeeper/src \
    /zookeeper/$DISTRO_NAME.jar.asc \
    /zookeeper/$DISTRO_NAME.jar.md5 \
    /zookeeper/$DISTRO_NAME.jar.sha1; \
    apk del .build-deps

# Copy configuration generator script to bin
COPY zkGenConfig.sh zkOk.sh zkMetrics.sh /zookeeper/bin/

# Create a user for the zookeeper process and configure file system ownership
# for necessary directories and symlink the distribution as a user executable
RUN set -ex; \
    mkdir -p  /usr/share/zookeeper /tmp/zookeeper /usr/etc/; \
    chown -R "$ZOO_USER:$ZOO_USER" /$DISTRO_NAME /tmp/zookeeper; \
    chmod +x /zookeeper/bin/zkGenConfig.sh /zookeeper/bin/zkOk.sh /zookeeper/bin/zkMetrics.sh; \
    ln -s /conf/ /usr/etc/zookeeper; \
    ln -s /zookeeper/bin/* /usr/bin; \
    ln -s /zookeeper/$DISTRO_NAME.jar /usr/share/zookeeper/; \
    ln -s /zookeeper/lib/* /usr/share/zookeeper
