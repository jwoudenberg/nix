let
  sources = import ../nix/sources.nix;

  pkgs = import sources.nixpkgs { };

in pkgs.mkShell {
  buildInputs = [ pkgs.morph pkgs.terraform ];
  shellHook = ''
    export HCLOUD_TOKEN="$(pass show keys/hetzner_cloud_token)"
    export RESILIO_MUSIC_READONLY="$(pass show keys/resilio_music_readonly)"
  '';
}
