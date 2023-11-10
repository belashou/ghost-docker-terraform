#!/bin/sh
set -e

. init-credentials.sh

echo "Starting DB backup"

mysqldump --host "${MYSQL_HOST}" --port "${MYSQL_PORT}" \
          --add-drop-database --databases "${MYSQL_DATABASE}" \
          --column-statistics=0 --single-transaction \
          | gzip > "${MYSQL_BACKUP_FOLDER_ON_KOPIA}/dump.sql.gz"

echo "DB backup finished"