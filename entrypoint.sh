#!/bin/bash
set -euo pipefail

if [[ $# -ne 0 ]]; then
    if [[ "$@" == "start-backup-now" ]]; then
        /opt/restic/backup.sh
        exit 0
    fi

    # If command are passed to docker container execute restic
    restic "$@"
    exit 0
fi

echo "$BACKUP_CRON flock -n /opt/restic/backup.lockfile /opt/restic/backup.sh" > /main.crontab

supercronic /main.crontab
