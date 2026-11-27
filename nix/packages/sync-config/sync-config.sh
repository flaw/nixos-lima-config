#!/bin/bash
# Update and activate the guest's NixOS configuration.
set -euo pipefail

if [[ ${1:-} == --help || ${1:-} == -h ]]; then
    echo "Usage: sync-config [config-name]"
    echo "Default config-name: nixos"
    exit 0
fi

if [[ $# -gt 1 ]]; then
    echo "Usage: sync-config [config-name]" >&2
    exit 1
fi

config_name=${1:-nixos}
sudo git -C /etc/nixos pull --ff-only
sudo nixos-rebuild switch --flake "/etc/nixos#$config_name"

echo "Configuration switched."
check-config-reboot
