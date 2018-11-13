FROM centos:7.5.1804

LABEL maintainer="Don Tregonning <dtregonning@splunk.com>, Chaitanya Phalak <cphalak@splunk.com>"
LABEL Description="Splunk Connect for Kubernetes docker image" Vendor="Splunk Inc." Version="1.1.Alpha"

COPY *.gem /tmp/
RUN curl -L -o /tmp/epel-release-7-11.noarch.rpm http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm \
 && rpm -Uvh /tmp/epel-release*rpm \
 && yum -y update \
 && yum install -y jemalloc jq-devel \
 && yum -y groupinstall "Development Tools" \
 && yum -y install libxslt-devel libyaml-devel libxml2-devel gdbm-devel libffi-devel zlib-devel openssl-devel libyaml-devel readline-devel curl-devel openssl-devel pcre-devel git memcached-devel valgrind-devel mysql-devel ImageMagick-devel ImageMagick \
 && cd /usr/local/src \
 && curl -L -o ruby-2.5.1.tar.gz https://cache.ruby-lang.org/pub/ruby/2.5/ruby-2.5.1.tar.gz \
 && tar zxvf ruby-2.5.1.tar.gz \
 && cd ruby-2.5.1 \
 && ./configure \
 && make \
 && make install \
 && gem install -N fluentd:1.3.0 \
                   fluent-plugin-systemd:1.0.1 \
                   fluent-plugin-concat:2.3.0 \
                   fluent-plugin-prometheus:1.2.1 \
                   fluent-plugin-jq:0.5.1 \
                   fluent-plugin-record-modifier:1.1.0 \
                   fluent-plugin-splunk-hec:1.0.1 \
                   oj:3.7.1 \
 && gem install -N /tmp/*.gem \
 && curl -L -o /usr/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 \
 && chmod +x /usr/bin/dumb-init \
 && curl -L -o /usr/bin/gosu https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64 \
 && chmod +x /usr/bin/gosu \
 && rm -rf /tmp/* /var/tmp/* $GEM_HOME/cache/*.gem \
 && mkdir -p /fluentd/{etc,log,plugins}

# from `repoquery -l jemalloc`
ENV LD_PRELOAD="/usr/lib64/libjemalloc.so.1" \
    FLUENTD_CONF="fluent.conf" \
    FLUENTD_OPT="" \
    DUMB_INIT_SETSID=0

COPY entrypoint.sh /bin/entrypoint.sh
ENTRYPOINT ["/bin/entrypoint.sh"]

CMD exec fluentd -c /fluentd/etc/${FLUENTD_CONF} -p /fluentd/plugins $FLUENTD_OPT