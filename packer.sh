#!/usr/bin/env bash

#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
BUILD_DIR="${ROOT_DIR}/builds"
export PACKER_BUILD_DIR="$(mktemp -d "${BUILD_DIR}/bld.XXXXXXXX")"
export PACKER_CACHE_DIR="${ROOT_DIR}/cache"
echo "Building in ${PACKER_BUILD_DIR} using cache ${PACKER_CACHE_DIR}..."

ARGS=( $@ )
for i in ${!ARGS[@]}; do
  if [ -f "${ARGS[$i]}" ]; then
    ARGS[$i]="$(realpath "${ARGS[$i]}")"
  fi
done

pushd "$PACKER_BUILD_DIR" >/dev/null
packer ${ARGS[@]} || true
popd >/dev/null
