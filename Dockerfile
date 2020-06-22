#FROM quay.io/openshift/origin-cli:latest
FROM registry.access.redhat.com/ubi8/ubi:8.2

RUN dnf install openssl openssl-devel git socat -y

RUN openssl version
RUN git version

RUN mkdir -p /tmp/tools

ADD https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz /tmp/tools/

RUN cd /tmp/tools && \
    tar -xzf openshift-client-linux.tar.gz && \
    mv oc /usr/bin/oc && \
    mv kubectl /usr/bin/kubectl && \
    cd ~

RUN oc version
RUN kubectl version


