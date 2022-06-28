FROM registry.redhat.io/openshift4/ose-cli:v4.10.0-202206211856.p0.g45460a5.assembly.stream

# Home directories required by acme.sh script.
ENV OCP_TOOLS_VERSION=4.10
ENV ACME_VERSION=2.8.6

WORKDIR /scripts

COPY scripts .

# OpenSSL, curl and socat required for script.
RUN dnf makecache && \
    dnf install -y \
    openssl socat curl \
    && dnf clean all && rm -rf /var/cache/dnf/*

WORKDIR /download

RUN curl https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-$OCP_TOOLS_VERSION/openshift-client-linux.tar.gz | tar -xz && \
    mv oc /usr/bin/oc && \
    mv kubectl /usr/bin/kubectl

WORKDIR /source

RUN curl -L https://github.com/acmesh-official/acme.sh/archive/$ACME_VERSION.tar.gz | tar -xz

WORKDIR /