FROM registry.access.redhat.com/ubi8/ruby-25

MAINTAINER DataEdge DataEdge@splunk.com

ARG VERSION

LABEL name="Splunk Connect for Kubernetes Metrics container" \
      maintainer="DataEdge@splunk.com" \
      vendor="Splunk Inc." \
      version=${VERSION} \
      release=${VERSION} \
      summary="Splunk Connect for Kubernetes Metrics container" \
      description="Splunk Connect for Kubernetes Metrics container"

ENV VERSION=${VERSION}
ENV FLUENT_USER fluent

USER root

COPY lib/fluent/plugin/*.rb /tmp/
COPY LICENSE /licenses/

COPY docker/Gemfile* ./
RUN gem install bundler \
   && bundle install 

RUN groupadd -r $FLUENT_USER && \
  useradd -r -g $FLUENT_USER $FLUENT_USER && \
  mkdir -p /fluentd/log fluentd/etc /fluentd/plugins && \
  cp /tmp/*.rb /fluentd/plugins/ && \
  chown -R $FLUENT_USER /fluentd && chgrp -R $FLUENT_USER /fluentd

USER $FLUENT_USER
CMD exec fluentd -p /fluentd/plugins -c /fluentd/etc/fluent.conf
