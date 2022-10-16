{ pkgs, flakeInputs, ... }: {
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ flakeInputs.self.overlays.linuxCustomPkgs ];
  nix.registry.nixpkgs.flake = flakeInputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=${flakeInputs.nixpkgs}" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
