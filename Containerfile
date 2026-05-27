# https://quay.io/repository/fedora/fedora-coreos?tab=tags
# skopeo inspect docker://quay.io/fedora/fedora-coreos:stable | jq -r '"quay.io/fedora/fedora-coreos:\(.Labels."org.opencontainers.image.version")@\(.Digest)"'
FROM quay.io/fedora/fedora-coreos:44.20260419.3.1@sha256:375ae15a4ffd30521e07f64af025fed0553c00e1ca1e3029b7eeec26fa390468

ENV INSTALL_K3S_VERSION=v1.32.11+k3s3
ENV INSTALL_FRR_VERSION=10.5.0-8.fc44
ENV INSTALL_LIBVIRT_VERSION=12.0.0-3.fc44
ENV INSTALL_QEMU_VERSION=10.2.2-1.fc44
ENV INSTALL_OVS_VERSION=3.6.2-1.fc44

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

    # Workaround for https://github.com/coreos/fedora-coreos-tracker/issues/572
    dnf swap -y nfs-utils-coreos nfs-utils

    dnf install -y \
        frr-$INSTALL_FRR_VERSION \
        openvswitch-$INSTALL_OVS_VERSION \
        libvirt-client-$INSTALL_LIBVIRT_VERSION libvirt-daemon-kvm-$INSTALL_LIBVIRT_VERSION \
        qemu-kvm-$INSTALL_QEMU_VERSION \
        cephadm ceph-common \
        tcpdump iperf3 htop \
        puppet systemd-journal-remote smartmontools

    dnf clean all
    rm -rf /var/run
    ostree container commit
EOF

RUN <<EOF
    sed -i 's/bind to =.*/bind to = 0.0.0.0/' /etc/netdata/netdata.conf
    echo 'enable netdata.service' >> /etc/systemd/system-preset/99-netdata.preset
    ostree container commit
EOF
