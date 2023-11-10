#!/bin/sh
set -e

. init-credentials.sh

gunzip < "${MYSQL_BACKUP_FOLDER_ON_KOPIA}/dump.sql.gz" | mysql

echo "DB restore finished"