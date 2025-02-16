#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <config1.bu> [config2.bu ...]"
    exit 1
fi


IGN_FILES=()

for CONFIG in "$@"; do
    if [[ ! -f "$CONFIG" ]]; then
        echo "Error: File '$CONFIG' not found!"
        exit 1
    fi

    BASENAME=$(basename "$CONFIG" .bu)
    IGN_FILE="${BASENAME}.ign"

    podman run --rm -i quay.io/coreos/butane:release --pretty --strict < "$CONFIG" > build/"$IGN_FILE"
    IGN_FILES+=("$IGN_FILE")
done

IGN_ARGS=()
for IGN_FILE in "${IGN_FILES[@]}"; do
    IGN_ARGS+=("--dest-ignition" "$IGN_FILE")
done

cd "$(dirname "$0")"/build
[[ -f ignited.iso ]] && rm ignited.iso

podman run --security-opt label=disable --pull=always --rm -v .:/data -w /data \
    quay.io/coreos/coreos-installer:release \
    iso customize "${IGN_ARGS[@]}" --dest-device /dev/sda --dest-console=tty0 --dest-console ttyS0,115200n8 \
    -o ignited.iso fcos-custom-live-iso.x86_64.iso
