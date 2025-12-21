# https://quay.io/repository/fedora/fedora-coreos?tab=tags
# skopeo inspect docker://quay.io/fedora/fedora-coreos:stable | jq -r '"quay.io/fedora/fedora-coreos:\(.Labels."org.opencontainers.image.version")@\(.Digest)"'
FROM quay.io/fedora/fedora-coreos:43.20251120.3.0@sha256:ce746b7118464d58b7d5a55d496cfb48dee83c59d3db4de34f33a05a332c6513

ENV INSTALL_K3S_VERSION=v1.31.5+k3s1
ENV INSTALL_FRR_VERSION=10.4.1-2.fc43
ENV INSTALL_LIBVIRT_VERSION=11.6.0-2.fc43
ENV INSTALL_QEMU_VERSION=10.1.3-1.fc43
ENV INSTALL_OVS_VERSION=3.6.0-2.fc43

ENV INSTALL_K3S_BIN_DIR=/usr/bin
ENV INSTALL_K3S_SYSTEMD_DIR=/usr/lib/systemd/system
ENV INSTALL_K3S_SKIP_ENABLE=true
ENV INSTALL_K3S_SKIP_START=true

COPY install-k3s.sh /tmp/install-k3s.sh
RUN sh /tmp/install-k3s.sh && \
    rm /tmp/install-k3s.sh && \
    ln -s ../k3s.service /usr/lib/systemd/system/multi-user.target.wants/k3s.service && \
    ostree container commit

RUN <<EOF
    set -euo pipefail

    dnf install -y \
        frr-$INSTALL_FRR_VERSION \
        openvswitch-$INSTALL_OVS_VERSION \
        libvirt-client-$INSTALL_LIBVIRT_VERSION libvirt-daemon-kvm-$INSTALL_LIBVIRT_VERSION \
        qemu-kvm-$INSTALL_QEMU_VERSION \
        cephadm ceph-common \
        tcpdump iperf3 htop \
        netdata smartmontools

    dnf clean all
    rm -rf /var/run
    ostree container commit
EOF

RUN <<EOF
    sed -i 's/bind to =.*/bind to = 0.0.0.0/' /etc/netdata/netdata.conf
    echo 'enable netdata.service' >> /etc/systemd/system-preset/99-netdata.preset
    ostree container commit
EOF
