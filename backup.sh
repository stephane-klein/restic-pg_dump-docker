#!/bin/sh

start=`date +%s`
echo "Starting pg_dump at $(date +"%Y-%m-%d %H:%M:%S")"
export PGPASSWORD=${POSTGRES_PASSWORD}
pg_dumpall -U ${POSTGRES_USER} -h ${POSTGRES_HOST} --globals-only -f /data/globals-only.sql
pg_dump -U ${POSTGRES_USER} -h ${POSTGRES_HOST} ${POSTGRES_DB} -Fc -f /data/database.Fc.dump

end=`date +%s`
echo "Finished pg_dump at $(date +"%Y-%m-%d %H:%M:%S") after $((end-start)) seconds"

/bin/backup-restic