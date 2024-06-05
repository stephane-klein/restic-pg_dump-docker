ARG ALPINE_VERSION=3.20

FROM alpine:$ALPINE_VERSION AS BASE

ARG RESTIC_FTP_DOCKER_VERSION=0.16.4
ARG RCLONE_VERSION=1.66.0

ARG SUPERCRONIC_VERSION=0.2.29
ARG SUPERCRONIC=supercronic-linux-amd64
ARG SUPERCRONIC_SHA1SUM=cd48d45c4b10f3f0bfdd3a57d054cd05ac96812b

ARG PG_BACK_VERSION=2.3.0

RUN apk add --no-cache zip curl \
    # Install restic
    && wget -O "/tmp/restic.bz2" https://github.com/restic/restic/releases/download/v${RESTIC_FTP_DOCKER_VERSION}/restic_${RESTIC_FTP_DOCKER_VERSION}_linux_amd64.bz2 \
        && bzip2 -d "/tmp/restic.bz2" \
    # Install rclone
    && wget -O "/tmp/rclone.zip" https://github.com/rclone/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-amd64.zip \
        && unzip -d "/tmp/" "/tmp/rclone.zip" \
        && mv "/tmp/rclone-v$RCLONE_VERSION-linux-amd64" "/tmp/rclone" \
    # Install supercronic
    && curl -fsSLO "https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-amd64" \
        && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
        && chmod +x "$SUPERCRONIC" \
        && mv "$SUPERCRONIC" "/tmp/supercronic" \
    && curl -fsSLO "https://github.com/orgrim/pg_back/releases/download/v${PG_BACK_VERSION}/pg-back_${PG_BACK_VERSION}_linux_amd64.deb" \
    # Install pg_pack
    && wget -O "/tmp/pg_back.tar.gz" https://github.com/orgrim/pg_back/releases/download/v${PG_BACK_VERSION}/pg_back_${PG_BACK_VERSION}_linux_amd64.tar.gz \
        && tar xfz "/tmp/pg_back.tar.gz" -C /tmp/

FROM alpine:$ALPINE_VERSION

RUN apk add --no-cache \
    bash \
    postgresql-client # pg_back need pg_dump, then PostgreSQL version 16.3 is installed

COPY --from=BASE --chmod=0755 /tmp/restic /usr/local/bin/restic
COPY --from=BASE --chmod=0755 /tmp/rclone/rclone /usr/local/bin/rclone
COPY --from=BASE --chmod=0755 /tmp/supercronic /usr/local/bin/supercronic
COPY --from=BASE --chmod=0755 /tmp/pg_back /usr/local/bin/pg_back

COPY --chmod=0755 ./backup.sh /opt/restic/backup.sh
COPY --chmod=0755 ./entrypoint.sh /opt/restic/entrypoint.sh

ENV RESTIC_PASSWORD=""
ENV RESTIC_TAG=""

ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=password
ENV POSTGRES_HOST=postgres
ENV POSTGRES_DB=postgres

ENV BACKUP_CRON="0 */6 * * *"

ENTRYPOINT [ "/opt/restic/entrypoint.sh" ]
