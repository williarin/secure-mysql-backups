FROM alpine:3.15 AS base

RUN apk --update add \
        tzdata \
        bash \
        tar \
        pigz \
        coreutils \
        mysql-client \
        mariadb-connector-c \
        openssl \
        logrotate \
    && rm -rf /var/cache/apk/* \
    && mkdir /backup \
    && chmod 755 /backup

COPY ./src/ /usr/local/bin
COPY ./logrotate.d/* /etc/logrotate.d/

CMD [ "run" ]


FROM base AS dev

COPY --from=trajano/alpine-libfaketime  /faketime.so /lib/faketime.so
ENV LD_PRELOAD=/lib/faketime.so
