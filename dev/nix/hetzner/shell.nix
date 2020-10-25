let
  sources = import ../nix/sources.nix;

  pkgs = import sources.nixpkgs { };

  withSecrets = pkgs.writeShellScriptBin "with-secrets" ''
    #!/usr/bin/env bash

    set -euo pipefail

    # For terraform
    export HCLOUD_TOKEN="$(pass show keys/hetzner_cloud_token)"
    export CLOUDFLARE_EMAIL="$(pass show cloudflare.com | grep email | awk '{print $2}')"
    export CLOUDFLARE_API_TOKEN="$(pass show keys/cloudflare_api_token)"

    # For nix deploys
    export RESILIO_MUSIC_READONLY="$(pass show keys/resilio_music_readonly)"
    exec "$@"
  '';

in pkgs.mkShell { buildInputs = [ pkgs.morph pkgs.terraform withSecrets ]; }
