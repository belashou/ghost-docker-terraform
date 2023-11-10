#!/bin/sh
set -e

echo "Cleaning dumps"

rm -rf "${MYSQL_BACKUP_FOLDER_ON_KOPIA:?}"/*
