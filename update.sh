#!/usr/bin/env bash

#
# Copies the current OS nixOS configuration and commits it
# Inspiration: https://www.youtube.com/watch?v=5aBUsLQVZYg
#

# No errors!!!!!!!
set -e

# Get the current git branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Get the current UNIX timestamp
TIMESTAMP=$(date +%s)

TAG="${BRANCH}-${TIMESTAMP}"

# Copy the current configuration
cp /etc/nixos/configuration.nix .
cp /etc/nixos/flake.nix .

# Add the configuration in case it doesn't exist for some reason
git add configuration.nix
git add flake.nix

git commit -m "Build: ${TAG}"

