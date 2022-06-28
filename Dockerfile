FROM registry.redhat.io/openshift4/ose-cli:v4.10.0-202206211856.p0.g45460a5.assembly.stream

# Home directories required by acme.sh script.
ENV ACME_VERSION=2.9.0

WORKDIR /scripts

COPY scripts .

# OpenSSL, curl and socat required for script.
RUN dnf makecache && \
    dnf install -y \
    openssl socat curl \
    && dnf clean all && rm -rf /var/cache/dnf/*

WORKDIR /source

RUN curl -L https://github.com/acmesh-official/acme.sh/archive/$ACME_VERSION.tar.gz | tar -xz

WORKDIR /