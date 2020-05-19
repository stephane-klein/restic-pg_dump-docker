FROM postgres:12.2-alpine AS postgres

FROM stephaneklein/restic-backup-docker:1.2-0.9.4

COPY --from=postgres /usr/local/bin/pg_dumpall /usr/local/bin/pg_dumpall
COPY --from=postgres /usr/local/bin/pg_dump /usr/local/bin/pg_dump
COPY --from=postgres /usr/local/lib/libpq.so.5 /usr/local/lib/libpq.so.5

RUN mv /bin/backup /bin/backup-restic
ADD /backup.sh /bin/backup
RUN chmod u+x /bin/backup

ENV POSTGRES_USER=post$gres
ENV POSTGRES_PASSWORD=password
ENV POSTGRES_HOST=postgres
ENV POSTGRES_DB=postgres
ENV RESTIC_REPOSITORY=/data/