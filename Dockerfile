ARG ALPINE_VERSION=3.20

FROM alpine:$ALPINE_VERSION AS BASE

ARG TARGETOS
ARG TARGETARCH

ARG RESTIC_VERSION=0.16.4
ARG RCLONE_VERSION=1.66.0
ARG SUPERCRONIC_VERSION=0.2.29

ARG PG_BACK_VERSION=2.3.0

RUN apk add --no-cache zip curl \
    # Install restic
    && wget -O "/tmp/restic.bz2" https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_${TARGETOS}_${TARGETARCH}.bz2 \
        && bzip2 -d "/tmp/restic.bz2" \
    # Install rclone
    && wget -O "/tmp/rclone.zip" https://github.com/rclone/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-${TARGETOS}-${TARGETARCH}.zip \
        && unzip -d "/tmp/" "/tmp/rclone.zip" \
        && mv "/tmp/rclone-v$RCLONE_VERSION-${TARGETOS}-${TARGETARCH}" "/tmp/rclone" \
    # Install supercronic
    && curl -fsSLO "https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-${TARGETOS}-${TARGETARCH}" \
        && mv "supercronic-${TARGETOS}-${TARGETARCH}" "/tmp/supercronic" \
    # Install pg_pack
    && wget -O "/tmp/pg_back.tar.gz" https://github.com/orgrim/pg_back/releases/download/v${PG_BACK_VERSION}/pg_back_${PG_BACK_VERSION}_linux_amd64.tar.gz \
        && tar xfz "/tmp/pg_back.tar.gz" -C /tmp/

FROM --platform=$BUILDPLATFORM alpine:$ALPINE_VERSION

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

# Daily
ENV BACKUP_CRON="0 3 * * *"

ENTRYPOINT [ "/opt/restic/entrypoint.sh" ]
