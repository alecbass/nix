#!/usr/bin/env bash
###
### Rebuilds the kernel. If /boot is full, try deleted old entries from /boot/kernels
###

if [[ $(whoami) != "root" ]]; then
    echo "Must be run as root"
    exit 1
fi

nixos-rebuild switch --flake .#default
