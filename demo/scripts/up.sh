#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

source .envrc
docker compose up -d postgres minio --wait

./scripts/import-demo-to-postgresql.sh

docker compose up -d
