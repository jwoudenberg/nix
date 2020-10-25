let
  sources = import ../nix/sources.nix;

  pkgs = import sources.nixpkgs { };

  withSecrets = pkgs.writeShellScriptBin "with-secrets" ''
    #!/usr/bin/env bash

    set -euo pipefail

    export HCLOUD_TOKEN="$(pass show keys/hetzner_cloud_token)"
    export RESILIO_MUSIC_READONLY="$(pass show keys/resilio_music_readonly)"
    exec "$@"
  '';

in pkgs.mkShell { buildInputs = [ pkgs.morph pkgs.terraform withSecrets ]; }
