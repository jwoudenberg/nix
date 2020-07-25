#!/usr/bin/env bash

set -eoux pipefail

# Regenerate the `deps.nix` file based on a git ref.
#
# Usage: ./update-deps.sh <git-ref>

REF="${1:?Pass a git ref to update to}"

# Update NPM dependencies
pushd frontend || exit
curl -LO --fail "https://raw.githubusercontent.com/filebrowser/filebrowser/$REF/frontend/package.json"
curl -LO --fail "https://raw.githubusercontent.com/filebrowser/filebrowser/$REF/frontend/package-lock.json"
nix-shell -p nodePackages.node2nix --run "
  node2nix\
    --development\
    --input package.json\
    --lock package-lock.json\
    --supplement-input supplement.json
"
rm package.json package-lock.json
popd

# Update Go dependencies
curl -LO --fail "https://raw.githubusercontent.com/filebrowser/filebrowser/$REF/go.mod"
curl -LO --fail "https://raw.githubusercontent.com/filebrowser/filebrowser/$REF/go.sum"
nix-shell -p vgo2nix --run vgo2nix
rm go.mod go.sum
