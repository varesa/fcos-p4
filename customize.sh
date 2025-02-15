#!/usr/bin/env bash

set -euo pipefail

CONFIG="${1:-}"

if [[ -z "$CONFIG" || ! -f "$CONFIG" ]]; then
    echo "Usage: $0 <config path>"
    exit 1
else
    CONFIG="$(realpath "$CONFIG")"
fi

cd "$(dirname "$0")"/build

podman run --rm -i \
    quay.io/coreos/butane:release \
    --pretty --strict < "$CONFIG" > config.ign

[[ -f ignited.iso ]] && rm ignited.iso

podman run --security-opt label=disable --pull=always --rm -v .:/data -w /data \
    quay.io/coreos/coreos-installer:release \
    iso customize --dest-ignition config.ign --dest-device /dev/sda --dest-console=tty0 --dest-console ttyS0,115200n8 \
    -o ignited.iso fcos-custom-live-iso.x86_64.iso
