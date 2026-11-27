#!/bin/bash
# Compare boot-only artifacts, not the whole system generation: most changes
# can be activated without a reboot. Optional paths also allow offline checks.
set -euo pipefail

booted_system=${1:-/run/booted-system}
current_system=${2:-/run/current-system}
reboot_command=${3:-sudo reboot}

if [[ ! -e "$booted_system/kernel" || ! -e "$current_system/kernel" ]]; then
    echo "Reboot status unknown: booted/current kernel artifacts are unavailable."
    exit 0
fi

changed=()
for artifact in kernel kernel-modules initrd kernel-params; do
    booted="$booted_system/$artifact"
    current="$current_system/$artifact"

    if [[ ! -e "$booted" && ! -e "$current" ]]; then
        continue
    elif [[ ! -e "$booted" || ! -e "$current" ]]; then
        changed+=("$artifact")
    elif [[ "$artifact" == kernel-params ]]; then
        if ! cmp -s "$booted" "$current"; then
            changed+=("$artifact")
        fi
    elif [[ $(readlink -f "$booted") != $(readlink -f "$current") ]]; then
        changed+=("$artifact")
    fi
done

if [[ ${#changed[@]} -gt 0 ]]; then
    echo "Reboot recommended: changed since boot: ${changed[*]}."
    echo "Run: $reboot_command"
else
    echo "No reboot needed for the checked boot artifacts."
fi
