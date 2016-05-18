#!/bin/sh

#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

ROOT_DIR="$(dirname $(readlink -fn $0))"

# Exit statuses, modelled after sysexits.h
EX_USAGE=64
EX_UNAVAILABLE=69
EX_CANTCREATE=73

# Trap an error and exit cleanly.
error_trap() {
    echo " "
    echo "$0: an error occurred during the execution of an action; aborting"
    echo " "
    exit 69
}

# Disable error trapping.
#
# Don't forget to re-enable it!
disable_error_trap() {
    trap - 1 2 3 15 ERR
}

# (Re-)enable error trapping.
enable_error_trap() {
    trap error_trap 1 2 3 15 ERR
}

# Ensure arguments are sane
ensure_sane_args() {
    if [ ! -f "$TEMPLATE_FILE" ]; then
        echo "[!] Template "${TEMPLATE}" does not exist in the templates directory"
        echo "[!] Did you type it correctly?"
    fi
}

# Ensure environment is sane
ensure_sane_env() {
    if [ ! -d "$PACKER_PATH" ]; then
        echo "[!] PACKER_PATH does not exist"
        echo "[!] Download the Packer utilities and update make-vm.conf.sh"
        exit $EX_UNAVAILABLE
    fi
}

enable_error_trap

# Source configuration and dependencies
. "${ROOT_DIR}/make-vm.conf.sh"

# Parse CLI arguments
eval set -- "$(getopt -o "t:" --long "template:" -- "$@")"
while true; do
    case "$1" in
        -t|--template) TEMPLATE="$2" ; shift 2 ;;
        *            ) break         ;         ;;
    esac
done

# Set up some other state before sanity checks
TEMPLATE_FILE="${ROOT_DIR}/templates/${TEMPLATE}/template.json"

# Ensure configuration and CLI arguments are relatively sane
ensure_sane_env
ensure_sane_args

# Put the Packer utilities on our path to save typing
PATH="${PACKER_PATH}:${PATH}"

# Set Packer's cache directory outside of the build directory for faster builds
export PACKER_CACHE_DIR="${ROOT_DIR}/cache"

# Build it
BUILD_DIR="${ROOT_DIR}/builds/${TEMPLATE}"
if [ -d "$BUILD_DIR" ]; then
    echo "[!] Build directory for "${TEMPLATE}" already exists; aborting"
    echo "[!] Delete or move aside the build directory to continue"
    exit $EX_CANTCREATE
fi
mkdir -p "$BUILD_DIR"
pushd "$BUILD_DIR"
packer build "$TEMPLATE_FILE"
popd
