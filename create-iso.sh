#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"/build
HASH="$(git rev-parse HEAD)"

skopeo copy containers-storage:registry.acl.fi/public/fcos:latest "oci-archive:install-$HASH"
sudo ../custom-coreos-disk-images.sh --ociarchive "install-$HASH" --platforms live
rm "install-$HASH" install-*-initramfs.x86_64.img install-*-kernel.x86_64  install-*-rootfs.x86_64.img
