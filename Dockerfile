FROM registry.access.redhat.com/ubi8/ubi:8.2

# Home directories required by acme.sh script.
ENV OCP_TOOLS_VERSION=4.4
ENV ACME_VERSION=2.8.6
ENV ACME_HOME=/tmp/acme
ENV CONFIG_HOME=/tmp/acme/config
ENV CERT_HOME=/tmp/acme/certs
ENV FINAL_CERTS=/tmp/certs/final

WORKDIR /scripts

COPY scripts/* .

# OpenSSL, git and socat required for script.
RUN dnf makecache && \
    dnf install -y \
    openssl socat curl \
    && dnf clean all && rm -rf /var/cache/dnf/*

WORKDIR /download

# ADD https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-$OCP_TOOLS_VERSION/openshift-client-linux.tar.gz .
RUN curl https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-$OCP_TOOLS_VERSION/openshift-client-linux.tar.gz | tar -xz && \
    mv oc /usr/bin/oc && \
    mv kubectl /usr/bin/kubectl

WORKDIR /source

RUN curl -L https://github.com/acmesh-official/acme.sh/archive/$ACME_VERSION.tar.gz | tar -xz && \
    alias acme.sh='/source/acme.sh/acme.sh'

WORKDIR /acme
