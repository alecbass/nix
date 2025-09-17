#!/usr/bin/env bash

set -e

nix-build -E 'let pkgs = import <nixpkgs> { }; in pkgs.callPackage ./package.nix {}' -A fetch-deps
./result

if [[ ! -f deps.json ]]; then
    echo "deps.json was not generated?"
    exit 1
fi
