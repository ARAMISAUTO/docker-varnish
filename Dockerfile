FROM debian:jessie

RUN \
  useradd -r -s /bin/false varnishd

# Install Varnish source build dependencies.
RUN \
  apt-get update && apt-get install -y --no-install-recommends \
    automake \
    build-essential \
    ca-certificates \
    curl \
    libedit-dev \
    libjemalloc-dev \
    libncurses-dev \
    libpcre3-dev \
    libtool \
    pkg-config \
    python-docutils \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install Varnish from source, so that Varnish modules can be compiled and installed.
ENV VARNISH_VERSION=4.1.10
ENV VARNISH_SHA256SUM=364833fbf6fb7540ddd54b62b5ac52b2fb00e915049c8446d71d334323e87c22
RUN \
  apt-get update && \
  mkdir -p /usr/local/src && \
  cd /usr/local/src && \
  curl -O https://varnish-cache.org/_downloads/varnish-${VARNISH_VERSION}.tgz && \
  echo "${VARNISH_SHA256SUM} varnish-$VARNISH_VERSION.tgz" | sha256sum -c - && \
  tar -xzf varnish-$VARNISH_VERSION.tgz && \
  cd varnish-$VARNISH_VERSION && \
  ./autogen.sh && \
  ./configure && \
  make install && \
  rm ../varnish-$VARNISH_VERSION.tgz

COPY start-varnishd.sh /usr/local/bin/start-varnishd

ENV VARNISH_PORT 80
ENV VARNISH_MEMORY 100m

EXPOSE 80
CMD ["start-varnishd"]

ONBUILD COPY default.vcl /etc/varnish/default.vcl
