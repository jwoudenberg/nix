#!/usr/bin/env bash

set -euo pipefail

export HOST="${1:?'Pass host'}"
export NIX_SSHOPTS="-t"

nixos-rebuild switch \
  --flake .#"$HOST" \
  --target-host "$HOST" \
  --use-remote-sudo \
  --use-substitutes
