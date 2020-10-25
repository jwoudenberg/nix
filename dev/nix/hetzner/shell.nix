let
  sources = import ../nix/sources.nix;

  pkgs = import sources.nixpkgs { };

  withSecrets = pkgs.writeShellScriptBin "with-secrets" ''
    #!/usr/bin/env bash

    set -euo pipefail

    # For terraform
    export HCLOUD_TOKEN="$(pass show hetzner.com | grep 'API-token' | awk '{print $2}')"
    export CLOUDFLARE_EMAIL="$(pass show cloudflare.com | grep email | awk '{print $2}')"
    export CLOUDFLARE_API_TOKEN="$(pass show cloudflare.com | grep 'API-token' | awk '{print $2}')"

    # For nix deploys
    export RESILIO_MUSIC_READONLY="$(pass show resilio.com | grep 'key-music-read-only' | awk '{print $2}')"
    exec "$@"
  '';

in pkgs.mkShell { buildInputs = [ pkgs.morph pkgs.terraform withSecrets ]; }
