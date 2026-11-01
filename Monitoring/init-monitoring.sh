#!/bin/sh
set -eu

: "${POSTGRES_EXPORTER_PASSWORD:?POSTGRES_EXPORTER_PASSWORD must be set}"

psql \
  --username "$POSTGRES_USER" \
  --dbname "$POSTGRES_DB" \
  --set ON_ERROR_STOP=1 \
  --set "exporter_password=$POSTGRES_EXPORTER_PASSWORD" \
  --set "database_name=$POSTGRES_DB" \
  --file /docker-entrypoint-initdb.d/monitoring.sql.in
