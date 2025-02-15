FROM quay.io/fedora/fedora-coreos:41.20250209.20.0@sha256:c865242cb8aaec3cc41b7715f30bb2c1598459fc90b89f03b7b6e994fa8ad888

RUN dnf install -y frr && \
    dnf clean all && \
    ostree container commit
