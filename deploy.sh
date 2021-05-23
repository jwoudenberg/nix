#!/usr/bin/env bash

# Adapted from Brian's deploy script here:
# https://git.bytes.zone/bytes.zone/infrastructure/src/commit/ac14708d9f8804ebcb2b445dc101bc8a5e464fe2/gitea/deploy.sh

set -exuo pipefail

export HOST="${1:?'Pass host'}"
nixos-rebuild build --flake ".#$HOST"
STORE_PATH=$(realpath result)

# Copy configuration
nix-copy-closure --use-substitutes --to "$HOST" "$STORE_PATH"

# Copy over secrets
write_secret () {
  SECRET=$(basename "$1" .gpg)
  pass show "$HOST/$SECRET" | ssh "$HOST" -T "cat > /var/secrets/$SECRET"
}
export -f write_secret
find ~/.password-store/ai-banana -type f \
  -exec bash -exuo pipefail -c 'write_secret "$1"' _ {} \;

# Activate new configuration
ssh "$HOST" -- "sudo nix-env --profile /nix/var/nix/profiles/system --set $STORE_PATH"
ssh "$HOST" -- "sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch"
