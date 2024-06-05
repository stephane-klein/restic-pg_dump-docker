#!/bin/bash
set -euo pipefail

start=`date +%s`
echo "Starting pg_back at $(date +"%Y-%m-%d %H:%M:%S")"
POSTGRES_PORT=${POSTGRES_PORT:-"5432"}
export PGPASSWORD=${POSTGRES_PASSWORD}
pg_back -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT}
# pg_back generate file in /var/backups/postgresql/

end=`date +%s`
echo "Finished pg_back at $(date +"%Y-%m-%d %H:%M:%S") after $((end-start)) seconds"

if ! restic unlock; then
    echo "Init restic repository..."
    restic init
fi

echo "Perform backup..."
retry_count=0
max_retries=5
# As a result of network problems or other types of issues that I can't remember,
# a loop is implemented here to make 5 backup attempts before returning an error.
while ! restic backup "/var/backups/postgresql/"; do
    retry_count=$((retry_count + 1))
    if [ $retry_count -ge $max_retries ]; then
        echo "Reached maximum retry limit of $max_retries. Exiting."
        exit 1
    fi
    echo "Sleeping for 10 seconds before retry..."
    sleep 10
done

# Delete dump file after upload by restic
rm /var/backups/postgresql/*

RESTIC_DOCKER_IS_FORGET_DISABLED=${RESTIC_DOCKER_IS_FORGET_DISABLED:-""}

if [[ ! ( $RESTIC_DOCKER_IS_FORGET_DISABLED == "1" || $RESTIC_DOCKER_IS_FORGET_DISABLED == "true" ) ]]; then
    echo "Forgetting old snapshots"
    retry_count=0
    max_retries=5
    while ! restic forget \
                    --compact \
                    --prune \
                    --keep-hourly="${RESTIC_KEEP_HOURLY:-24}" \
                    --keep-daily="${RESTIC_KEEP_DAILY:-7}" \
                    --keep-weekly="${RESTIC_KEEP_WEEKLY:-4}" \
                    --keep-monthly="${RESTIC_KEEP_MONTHLY:-12}"; do
        retry_count=$((retry_count + 1))
        if [ $retry_count -ge $max_retries ]; then
            echo "Reached maximum retry limit of $max_retries. Exiting."
            exit 1
        fi
        echo "Sleeping for 10 seconds before retry..."
        sleep 10
    done
fi

echo "Check repository"
restic check --no-lock

# Remove unwanted cache
rm -rf /tmp/restic-check-cache-*

echo 'Finished forget with prune successfully'
