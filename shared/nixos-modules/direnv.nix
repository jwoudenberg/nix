{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.direnv
    pkgs.nix-direnv
  ];
}
