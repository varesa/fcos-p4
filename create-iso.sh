#!/usr/bin/env bash

cd "$(dirname "$0")"/build || exit

podman run --rm -i quay.io/coreos/butane:release --pretty --strict < ../config.bu > config.ign
skopeo copy registry.acl.fi/public/fcos:latest oci-archive:fcos-custom
sudo ../custom-coreos-disk-images.sh --ociarchive fcos-custom --platforms live

