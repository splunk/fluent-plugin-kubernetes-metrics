FROM alpine:3.8

LABEL maintainer="Don Tregonning <dtregonning@splunk.com>, Chaitanya Phalak <cphalak@splunk.com>"
LABEL Description="Splunk Connect for Kubernetes docker image" Vendor="Splunk Inc." Version="1.1.Alpha"

ENV DUMB_INIT_VERSION=1.2.1
ENV SU_EXEC_VERSION=0.2

COPY *.gem /tmp/

ARG DEBIAN_FRONTEND=noninteractive
# Do not split this into multiple RUN!
# Docker creates a layer for every RUN-Statement
# therefore an 'apk delete' has no effect
RUN apk update \
 && apk upgrade \
 && apk add --no-cache \
        ca-certificates \
 && update-ca-certificates \
 && apk add --no-cache \
        ruby ruby-irb ruby-etc ruby-webrick ruby-json \
        su-exec==${SU_EXEC_VERSION}-r0 \
        dumb-init==${DUMB_INIT_VERSION}-r0 \
 && apk add --no-cache --virtual .build-deps \
        build-base \
        ruby-dev wget gnupg \
 && echo 'gem: --no-document' >> /etc/gemrc \
 && gem install -N \
         fluentd:1.3.3 \
         fluent-plugin-record-modifier:1.1.0 \
         fluent-plugin-splunk-hec:1.0.1 \
         oj:3.7.8 \
         multi_json:1.13.1 \
         bigdecimal:1.3.5 \
         kubeclient:4.2.2 \
 && gem install -N /tmp/*.gem \
 && apk del .build-deps \
 && rm -rf /var/cache/apk/* \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

ENV LD_PRELOAD="" \
    FLUENTD_CONF="fluent.conf" \
    FLUENTD_OPT="" \
    DUMB_INIT_SETSID=0

COPY entrypoint.sh /bin/entrypoint.sh
ENTRYPOINT ["/bin/entrypoint.sh"]

CMD exec fluentd -c /fluentd/etc/${FLUENTD_CONF} -p /fluentd/plugins $FLUENTD_OPT