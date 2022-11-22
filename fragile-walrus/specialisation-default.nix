{ pkgs, config, lib, ... }:

{
  config = let
    modules =
      [ ../shared/nixos-modules/sway.nix ../shared/nixos-modules/pipewire.nix ];
    otherConfig = { system.nixos.tags = [ "sway" ]; };
  in lib.mkIf (config.specialisation != { })
  (lib.fold lib.recursiveUpdate otherConfig
    (map (p: import p { pkgs = pkgs; }) modules));
}
