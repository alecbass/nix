#!/usr/bin/env bash

if [[ $(whoami) != "root" ]]; then
    echo "Must be run as root"
    exit 1
fi

nixos-rebuild switch --flake .#default
