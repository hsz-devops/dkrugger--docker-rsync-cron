FROM ez123/cron:latest

ENV \
    RSYNC_CRONTAB="0 0 * * *" \
    RSYNC_OPTIONS="--archive --timeout=3600" \
    RSYNC_UID="0" \
    RSYNC_GID="0" \
    USE_DATE_IN_DEST="1"

COPY rsync-entrypoint.sh /entrypoint.d/rsync.sh
COPY run-rsync.sh        /run-rsync.sh

RUN set -x; \
    apk add --no-cache --update \
        rsync sudo \
        bash \
        coreutils \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apk/* \
    \
    && chmod +x \
        /entrypoint.d/rsync.sh \
        /run-rsync.sh \
    && mkdir -p \
        /rsync_dir/0.src \
        /rsync_dir/9.dst \
    && chmod -R a+rwx \
        /rsync_dir \
    && echo done...

VOLUME ["/rsync_dir/0.src", "/rsync_dir/9.dst"]
