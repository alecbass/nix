#!/usr/bin/env bash

#
# Script to fix wifi when it doesn't start on system startup.
# This started being an issue in NixOS 25.05
#
# NOTE: This script should be run as sudo
#

set -e

if [[ $(whoami) != "root" ]]; then
  echo "This script should be run as sudo. Exiting..."
  exit 1
fi

modprobe -r b43 && modprobe -r bcma && modprobe -r wl && modprobe wl
