FROM quay.io/fedora/fedora-coreos:41.20250209.20.0@sha256:c865242cb8aaec3cc41b7715f30bb2c1598459fc90b89f03b7b6e994fa8ad888

ENV INSTALL_K3S_VERSION=v1.31.5+k3s1
RUN curl -sfL https://get.k3s.io | sh - 

RUN dnf install -y frr-10.2-2 && \
    dnf clean all && \
    ostree container commit
