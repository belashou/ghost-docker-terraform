#!/bin/bash

APP_DIR=/app
APP_ORIG_DIR=/app.orig
INIT_FILE=$APP_DIR/.initialized
#CONFIG_FILE=$APP_DIR/config/repository.config

# Extract default config, scripts and create symlinks
if [ ! -f "${INIT_FILE}" ]; then
    cp -a ${APP_ORIG_DIR}/. ${APP_DIR}
    ln -s ${APP_DIR}/scripts/*.sh /bin

    # Substitute vars from config
    # envsubst < ${CONFIG_FILE} > ${CONFIG_FILE}.tmp && mv ${CONFIG_FILE}.tmp ${CONFIG_FILE}

    touch ${INIT_FILE}
fi

if [ "${MYSQL_RESTORE_FROM_BACKUP_ON_START}" == "true" ] && [ "$(ls -A ${MYSQL_BACKUP_FOLDER_ON_KOPIA})" ]; then
    . restore.sh && . clean.sh
    MYSQL_RESTORE_FROM_BACKUP_ON_START='false'
fi

# Try to connect to existing repository and create config file
kopia repository connect s3 \
        --bucket="${S3_BACKUP_BUCKET}" \
        --access-key="${S3_ACCESS_KEY}" \
        --secret-access-key="${S3_SECRET_KEY}" \
        --endpoint="${S3_ENDPOINT}" \
        --password="${KOPIA_PASSWORD}" \
        --description='Main S3 repository' \
        --enable-actions

# If unable to connect (i.e. repo is new), setup repo and policies
if [ $? -ne 0 ]; then
    kopia repository create s3 \
            --bucket="${S3_BACKUP_BUCKET}" \
            --access-key="${S3_ACCESS_KEY}" \
            --secret-access-key="${S3_SECRET_KEY}" \
            --endpoint="${S3_ENDPOINT}" \
            --description='Main S3 repository' \
            --password="${KOPIA_PASSWORD}" \
            --enable-actions

    if [ $? -ne 0 ]; then
        echo "Unable to create a new repository"
        exit 1
    fi
    
    # Setup default backup policies
    kopia policy set "${GHOST_BACKUP_FOLDER_ON_KOPIA}" \
        --compression=pgzip \
        --snapshot-time-crontab='0 0 * * Sat'
    
    kopia policy set "${MYSQL_BACKUP_FOLDER_ON_KOPIA}" \
        --compression=pgzip \
        --snapshot-time-crontab='0 0 * * Sat' \
        --before-folder-action=backup.sh
fi

exec /bin/kopia $@