#!/bin/bash
set -ex

### extract year, month, day to create sub-directories and format date to append to backup name.

T_STAMP=$(date -u  "+%Y%m%d_%H%M%SZ")
echo "current timestamp is: ${T_STAMP}"

BACKUP_ROOT_SRC="/rsync_src"
BACKUP_ROOT_DST="/rsync_dst"

[ -d "${BACKUP_ROOT_SRC}" ] || exit -3
[ -d "${BACKUP_ROOT_DST}" ] || exit -4

CURRENT_YEAR="${T_STAMP:0:4}"
CURRENT_MONTH="${T_STAMP:4:2}"
CURRENT_DAY="${T_STAMP:6:2}"
CHILD_DIRECTORY_NAME="${T_STAMP}"
BACKUP_DIRECTORY="${BACKUP_ROOT_DST}/${CURRENT_YEAR}/${CURRENT_MONTH}/${CURRENT_DAY}/${CHILD_DIRECTORY_NAME}"
echo "backup directory created is : ${BACKUP_DIRECTORY}"


### create backups directory if not present
[ -d "${BACKUP_DIRECTORY}" ] || mkdir -p "${BACKUP_DIRECTORY}"

echo "the directory created is ${BACKUP_DIRECTORY}"
sudo -u "$1" -g "$2" \
    rsync \
        ${RSYNC_OPTIONS} \
        "${BACKUP_ROOT_SRC}" \
        "${BACKUP_DIRECTORY}"