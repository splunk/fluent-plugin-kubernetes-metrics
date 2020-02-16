FROM registry.access.redhat.com/ubi8/ruby-25

MAINTAINER DataEdge DataEdge@splunk.com

LABEL name="Splunk Connect for Kubernetes Metrics container" \
      maintainer="DataEdge@splunk.com" \
      vendor="Splunk Inc." \
      version="1.1.3" \
      release="1.1.3" \
      summary="Splunk Connect for Kubernetes Metrics container" \
      description="Splunk Connect for Kubernetes Metrics container"

ARG VERSION
ENV VERSION=${VERSION}
ENV FLUENT_USER fluent

USER root

COPY *.gem /tmp/
COPY licenses /licenses

COPY Gemfile* ./
RUN gem install bundler \
   && bundle add fluent-plugin-splunk-hec -v ${VERSION} \
   && bundle exec gem install /tmp/*.gem

RUN groupadd -r $FLUENT_USER && \
  useradd -r -g $FLUENT_USER $FLUENT_USER && \
  mkdir -p /fluentd/log fluentd/etc /fluentd/plugins &&\
  chown -R $FLUENT_USER /fluentd && chgrp -R $FLUENT_USER /fluentd

USER $FLUENT_USER
CMD exec fluentd -c /fluentd/etc/fluent.conf
