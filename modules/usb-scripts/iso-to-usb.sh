#!/usr/bin/env bash

# Write a .iso file to a usb stick.
#
#     iso-to-usb my-disk.iso /dev/sdx

set -euxo pipefail

ISO="${1:?missing first argument: path to .iso file}"
DEVICE="${2:?missing second argument: device to write to}"

exec dd bs=4M if="$ISO" of="$DEVICE" conv=fsync oflag=direct status=progress
