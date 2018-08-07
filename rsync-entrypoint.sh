#!/usr/bin/env bash

set -ex

# Make sure that the group and users specified by the user exist
if ! getent group "${DUMP_GID}" &>/dev/null; then
    addgroup -g "${DUMP_GID}" "${DUMP_USER_IF_NEW}"
fi
DUMP_GROUP="$(getent group "${DUMP_GID}" | cut -d: -f1)"

if ! getent passwd "${DUMP_UID}" &>/dev/null; then
    adduser -u "${DUMP_UID}" -D -H "${DUMP_USER_IF_NEW}" -G "${DUMP_GROUP}"
fi
DUMP_USER="$(getent passwd "${DUMP_UID}" | cut -d: -f1)"

if ! getent group "${DUMP_GROUP}" | grep "${DUMP_USER}" &>/dev/null; then
    addgroup "${DUMP_USER}" "${DUMP_GROUP}"
fi

# Setup our crontab entry
export CRONTAB_ENTRY="${DUMP_CRONTAB} bash /run-rsync.sh ${DUMP_USER} ${DUMP_GROUP}"
