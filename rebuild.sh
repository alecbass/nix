#!/usr/bin/env bash
###
### Rebuilds the kernel. If /boot is full, try deleted old entries from /boot/kernels
###

if [[ $(whoami) != "root" ]]; then
    echo "Must be run as root"
    exit 1
fi

profile=$1
profiles=("default" "laptop")

if [[ -z "$profile" ]]; then
    while [[ -z "$profile" ]]; do
        select profile in "${profiles[@]}"; do
            case $profile in
                "default")
                    echo "Selected profile $profile"
                    break;
                    ;;
                "laptop")
                    echo "Selected profile $profile"
                    break
                    ;;
                *)
                    echo "Invalid profile, please select again"
                    ;;
            esac
        done
    done
fi

echo "Rebuilding profile: $profile"

nixos-rebuild switch --flake ".#${profile}"
