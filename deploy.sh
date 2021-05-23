#!/usr/bin/env bash

# Adapted from Brian's deploy script here:
# https://git.bytes.zone/bytes.zone/infrastructure/src/commit/ac14708d9f8804ebcb2b445dc101bc8a5e464fe2/gitea/deploy.sh

set -exuo pipefail

HOST="${1:-}"
nixos-rebuild build --flake ".#$HOST"
STORE_PATH=$(realpath result)

nix-copy-closure --use-substitutes --to "$HOST" "$STORE_PATH"
ssh "$HOST" -- "sudo nix-env --profile /nix/var/nix/profiles/system --set $STORE_PATH"
ssh "$HOST" -- "sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch"
