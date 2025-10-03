FROM node:22-bookworm
LABEL authors="Squidward daddy"

WORKDIR /app

RUN apt update
RUN apt install -y \
    wget \
    curl \
    openssl \
    cron \
    socat \
    build-essential \
    libssl-dev

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# setup Squid
ARG SQUID_VERSION=7.1


RUN wget -q https://github.com/squid-cache/squid/releases/download/SQUID_${SQUID_VERSION//./_}/squid-${SQUID_VERSION}.tar.gz -O /tmp/squid.tgz \
    && mkdir /tmp/squid \
    && tar xzf /tmp/squid.tgz --strip-components=1 -C /tmp/squid

RUN cd /tmp/squid && ./configure \
        --prefix=/usr \
        --datadir=/usr/share/squid \
        --sysconfdir=/etc/squid \
        --libexecdir=/usr/lib/squid \
        --localstatedir=/var \
        --with-logdir=/var/log/squid \
        --disable-strict-error-checking \
        --disable-arch-native \
        --enable-removal-policies="lru,heap" \
        --enable-auth-basic="getpwnam" \
        --enable-log-daemon-helpers="file" \
        --enable-epoll \
        --disable-mit \
        --enable-delay-pools \
        --enable-arp-acl \
        --enable-openssl \
        --enable-ssl-crtd \
        --enable-linux-netfilter \
        --enable-ident-lookups \
        --enable-useragent-log \
        --enable-cache-digests \
        --enable-referer-log \
        --enable-async-io \
        --enable-truncate \
        --enable-arp-acl \
        --enable-htcp \
        --enable-carp \
        --enable-poll \
        --enable-follow-x-forwarded-for \
        --with-large-files \
        --with-default-user=squid \
        --with-openssl

RUN cd /tmp/squid && make
RUN cd /tmp/squid && make install

CMD tail -f /dev/null