#!/bin/bash
set -ex

echo $UID $GID $(whoami)

[ -z "$1" ] && echo "RSYNC UID parameter not specified" && exit -1
[ -z "$2" ] && echo "RSYNC GID parameter not specified" && exit -2

### extract year, month, day to create sub-directories and format date to append to backup name.
T_STAMP=$(date -u  "+%Y%m%d_%H%M%SZ")
echo "current timestamp is: ${T_STAMP}"

BACKUP_ROOT_SRC="/rsync_src"
BACKUP_ROOT_DST="/rsync_dst"

[ -d "${BACKUP_ROOT_SRC}" ] || exit -3
[ -d "${BACKUP_ROOT_DST}" ] || exit -4

if [ "${USE_DATE_IN_DEST}" == "1" ]; then
    CURRENT_YEAR="${T_STAMP:0:4}"
    CURRENT_MONTH="${T_STAMP:4:2}"
    CURRENT_DAY="${T_STAMP:6:2}"
    CHILD_DIRECTORY_NAME="${T_STAMP}"
    BACKUP_DIRECTORY="${BACKUP_ROOT_DST}/${CURRENT_YEAR}/${CURRENT_MONTH}/${CURRENT_DAY}/${CHILD_DIRECTORY_NAME}"

    ### create backups directory if not present
    mkdir -p "${BACKUP_DIRECTORY}"
else
    BACKUP_DIRECTORY="${BACKUP_ROOT_DST}"
fi

[ -d "${BACKUP_DIRECTORY}" ] || exit -5

## make sure folder is writeable by rsynccron
chown -R "$1":"$2" "${BACKUP_DIRECTORY}"

echo "backup directory: ${BACKUP_DIRECTORY}"

sudo -u "$1" -g "$2" \
    rsync \
        ${RSYNC_OPTIONS} \
        "${BACKUP_ROOT_SRC}" \
        "${BACKUP_DIRECTORY}"
