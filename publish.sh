#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

TMP="tmp-fcos-image-build"
REMOTE="registry.acl.fi/public/fcos"
DATE="$(date +%Y%m%d-%H%M%S)"
HASH="$(git rev-parse HEAD)"

if [ "$(git status --porcelain)" == "" ]; then
    CLEAN=true
else
    CLEAN=false
fi

podman build ${PODMAN_BUILD_OPTS:-} -t "$TMP" .

[ "$CLEAN" == "true" ] && podman tag "$TMP" "$REMOTE:$DATE-$HASH"
podman tag "$TMP" "$REMOTE:$DATE"
podman tag "$TMP" "$REMOTE:latest"

[ "$CLEAN" == "true" ] && podman push "$REMOTE:$DATE-$HASH"
podman push "$REMOTE:$DATE"
podman push "$REMOTE:latest"

echo Refs:
[ "$CLEAN" == "true" ] && echo "$REMOTE:$DATE-$HASH"
echo "$REMOTE:$DATE"
echo "$REMOTE:latest"
