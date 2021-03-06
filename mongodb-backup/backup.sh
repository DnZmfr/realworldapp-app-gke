#!/usr/bin/env bash
set -e

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

CURRENT_DT=$(date +%Y%m%d_%H%M)
BACKUP_FILENAME=mongodb_backup_${CURRENT_DT}.gz

bold "Back-up mongoDB database to ${BACKUP_FILENAME}"
mongodump --archive=${BACKUP_FILENAME} --gzip --uri ${MONGODB_URI}

bold "Copy backup file to Google Cloud Storage..."
gsutil cp ${BACKUP_FILENAME} ${GCS_BUCKET}

bold "Delete local backup file..."
rm -f ${BACKUP_FILENAME}

bold "Done. Backup complete."

