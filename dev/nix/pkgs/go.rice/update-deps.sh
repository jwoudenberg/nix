#!/usr/bin/env bash

set -eoux pipefail

# Regenerate the `deps.nix` file based on a git ref.
#
# Usage: ./update-deps.sh <git-ref>

REF="${1:?Pass a git ref to update to}"
curl -LO --fail "https://raw.githubusercontent.com/GeertJohan/go.rice/$REF/go.mod"
curl -LO --fail "https://raw.githubusercontent.com/GeertJohan/go.rice/$REF/go.sum"
nix-shell -p vgo2nix --run vgo2nix
rm go.mod go.sum
