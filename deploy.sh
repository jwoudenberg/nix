#!/usr/bin/env bash

# Adapted from Brian's deploy script here:
# https://git.bytes.zone/bytes.zone/infrastructure/src/commit/ac14708d9f8804ebcb2b445dc101bc8a5e464fe2/gitea/deploy.sh

set -euo pipefail

export HOST="${1:?'Pass host'}"

# Create a persistent ssh connection that will be reused by follow-up commands
echo "Opening ssh connection..."
nixos-rebuild switch --flake .#"$HOST" --target-host "$HOST" --use-remote-sudo

# Get password for reading machine secrets later
echo -n 'keepassxc password:'
read -s PASSWORD

# Copy over secrets
write_secret () {
  SECRET=$1
  echo "$PASSWORD" | keepassxc-cli show \
    -y 1 \
    --show-protected \
    --attributes Notes \
    ~/docs/passwords.kdbx "$HOST/$SECRET" \
    | ssh "$HOST" -T "cat > /run/secrets/$SECRET"
}
export -f write_secret
ssh "$HOST" -- "mkdir -p /run/secrets"
for pass in $(echo "$PASSWORD" | keepassxc-cli ls -y 1 ~/docs/passwords.kdbx "$HOST"); do
  write_secret "$pass"
done
