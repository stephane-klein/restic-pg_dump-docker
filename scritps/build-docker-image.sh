#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker build -t stephaneklein/restic-pg_dump .
