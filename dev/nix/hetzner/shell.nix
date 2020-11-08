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
    export $(pass show resilio.com | grep key_ | awk '{ print "RESILIO_" toupper($1) "=" $2}')
    pass show rsync.net | grep restic | awk '{ print $2 }' > /tmp/restic-password

    exec "$@"

    rm /tmp/restic-password
  '';

in pkgs.mkShell { buildInputs = [ pkgs.morph pkgs.terraform withSecrets ]; }
