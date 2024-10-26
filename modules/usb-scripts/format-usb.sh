#!/usr/bin/env bash

# Format a usb stick for carrying data.
#
#     format-usb /dev/sdx

set -euxo pipefail

DEVICE="${1:?missing argument: device to format}"

parted --script "$DEVICE" mklabel msdos
parted --script "$DEVICE" mkpart primary ext4 0% 100%
sleep 1 # New partition is not immediately available as a device
mkfs.exfat "$DEVICE"1
