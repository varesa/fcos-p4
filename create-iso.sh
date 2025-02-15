#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"/build

skopeo copy containers-storage:registry.acl.fi/public/fcos:latest oci-archive:fcos-custom
sudo ../custom-coreos-disk-images.sh --ociarchive fcos-custom --platforms live

