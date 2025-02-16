FROM quay.io/fedora/fedora-coreos:41.20250223.20.1@sha256:a3afb2d9e11ffd4504e783828f824ed91b1a20832eacca4cae62d63515e3dfd0

ENV INSTALL_K3S_VERSION=v1.31.5+k3s1
ENV INSTALL_FRR_VERSION=10.2-2.fc41

ENV INSTALL_K3S_BIN_DIR=/usr/bin
ENV INSTALL_K3S_SYSTEMD_DIR=/usr/lib/systemd/system
ENV INSTALL_K3S_SKIP_ENABLE=true
ENV INSTALL_K3S_SKIP_START=true

RUN curl -sfL https://get.k3s.io | sh - && \
    ln -s ../k3s.service /usr/lib/systemd/system/multi-user.target.wants/k3s.service

RUN dnf install -y frr-$INSTALL_FRR_VERSION && \
    dnf clean all && \
    rm -rf /var/run && \
    ostree container commit
