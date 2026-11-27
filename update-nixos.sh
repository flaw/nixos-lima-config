#!/bin/bash
# Update an existing Lima-NixOS guest from its configuration repository.
set -euo pipefail

DEFAULT_CONFIG_NAME='nixos'

display_help() {
    echo "Usage: $0 guest-hostname [config-name]"
    echo "Default config-name: $DEFAULT_CONFIG_NAME"
    echo "Pulls /etc/nixos from its configured remote and rebuilds with switch."
}

if [[ ${1:-} == --help || ${1:-} == -h ]]; then
    display_help
    exit 0
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
    display_help >&2
    exit 1
fi

GUEST_HOST_NAME=$1
GUEST_CONFIG_NAME=${2:-$DEFAULT_CONFIG_NAME}

limactl shell "$GUEST_HOST_NAME" -- sudo git -C /etc/nixos pull --ff-only
limactl shell "$GUEST_HOST_NAME" -- sudo nixos-rebuild switch \
    --flake "/etc/nixos#$GUEST_CONFIG_NAME"

echo "Configuration switched."
# Send the checker so this also works before it is installed in the guest.
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
limactl shell "$GUEST_HOST_NAME" -- bash -s -- \
    /run/booted-system /run/current-system "limactl restart $GUEST_HOST_NAME" \
    < "$SCRIPT_DIR/check-config-reboot.sh"
