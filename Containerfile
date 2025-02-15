FROM quay.io/fedora/fedora-coreos:41.20250214.20.0@sha256:7c29937bff875a19bda467a0759ec05428d48f64f9f0620b8a3296fc820fc424

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
