FROM quay.io/fedora/fedora-coreos:42.20250515.20.0@sha256:ce2a276c3d43996b6c07989514f81afa6626ce57954b85587f3c0eca0c08f1e6

ENV INSTALL_K3S_VERSION=v1.31.5+k3s1
ENV INSTALL_FRR_VERSION=10.2-4.fc42
ENV INSTALL_LIBVIRT_VERSION=11.0.0-1.fc42
ENV INSTALL_QEMU_VERSION=9.2.3-1.fc42
ENV INSTALL_OVS_VERSION=3.4.1-1.fc42

ENV INSTALL_K3S_BIN_DIR=/usr/bin
ENV INSTALL_K3S_SYSTEMD_DIR=/usr/lib/systemd/system
ENV INSTALL_K3S_SKIP_ENABLE=true
ENV INSTALL_K3S_SKIP_START=true

COPY install-k3s.sh /tmp/install-k3s.sh
RUN sh /tmp/install-k3s.sh && \
    rm /tmp/install-k3s.sh && \
    ln -s ../k3s.service /usr/lib/systemd/system/multi-user.target.wants/k3s.service

RUN dnf install -y \
        frr-$INSTALL_FRR_VERSION \
        openvswitch-$INSTALL_OVS_VERSION \
        libvirt-client-$INSTALL_LIBVIRT_VERSION libvirt-daemon-kvm-$INSTALL_LIBVIRT_VERSION \
        qemu-kvm-$INSTALL_QEMU_VERSION \
        tcpdump iperf3 \
    && \
    dnf clean all && \
    rm -rf /var/run && \
    ostree container commit
