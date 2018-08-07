#!/usr/bin/env bash
set -ex

echo $UID $GID $(whoami)

[ -z "$1" ] && echo "Cron job UID parameter not specified" && exit -1
[ -z "$2" ] && echo "Cron job GID parameter not specified" && exit -2

### extract year, month, day to create sub-directories and format date to append to backup name.
T_STAMP=$(date -u  "+%Y%m%d_%H%M%SZ")
echo "current timestamp is: ${T_STAMP}"

BACKUP_ROOT="/mnt_dir"
BACKUP_ROOT_SRC="${BACKUP_ROOT}/0.src"
BACKUP_ROOT_DST="${BACKUP_ROOT}/9.dst"

ls -la "${BACKUP_ROOT}" ||true
ls -la "${BACKUP_ROOT_SRC}" ||true
ls -la "${BACKUP_ROOT_DST}" ||true

[ -d "${BACKUP_ROOT_SRC}" ] || exit -3
[ -d "${BACKUP_ROOT_DST}" ] || exit -4

if [ "${USE_DATE_IN_DEST}" == "1" ]; then
    CURRENT_YEAR="${T_STAMP:0:4}"
    CURRENT_MONTH="${T_STAMP:4:2}"
    CURRENT_DAY="${T_STAMP:6:2}"
    CHILD_DIRECTORY_NAME="${T_STAMP}"
    BACKUP_DIR_DST="${BACKUP_ROOT_DST}/${CURRENT_YEAR}/${CURRENT_MONTH}/${CURRENT_DAY}/${CHILD_DIRECTORY_NAME}/"

    ### create backups directory if not present
    mkdir -p "${BACKUP_DIR_DST}"
else
    BACKUP_DIR_DST="${BACKUP_ROOT_DST}/"
fi

ls -la "${BACKUP_DIR_DST}" ||true
[ -d "${BACKUP_DIR_DST}" ] || exit -5

## make sure folder is writeable by the user
## but not recursivelly (there may already be some files from previous backups in same day)
chown "$1":"$2" "${BACKUP_DIR_DST}"

echo "backup directory: ${BACKUP_DIR_DST}"

ls -la "${BACKUP_ROOT_SRC}" ||true
pushd "${BACKUP_ROOT_SRC}"
sudo -u "$1" -g "$2" \
    rsync \
        ${RSYNC_OPTIONS} \
        "." \
        "${BACKUP_DIR_DST}" \

