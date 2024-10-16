{ pkgs, flakeInputs, ... }:
{
  nix.package = pkgs.lix;
  programs.nix-index.enable = true;
  programs.nix-index.enableZshIntegration = false;
  programs.nix-index.enableBashIntegration = false;
  programs.nix-index.enableFishIntegration = false;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ flakeInputs.self.overlays.linuxCustomPkgs ];
  nix.registry.nixpkgs.flake = flakeInputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=${flakeInputs.nixpkgs}" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 31d";
  };
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nix.settings.trusted-users = [ "@wheel" ];
  homedir.files.".config/nixpkgs/config.nix" = pkgs.writeText "config.nix" ''
    { allowUnfree = true; }
  '';
}
