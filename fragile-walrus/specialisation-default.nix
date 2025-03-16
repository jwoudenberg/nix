{
  pkgs,
  config,
  lib,
  ...
}:

{
  config =
    let
      modules = [ ../modules/niri.nix ];
      otherConfig = {
        system.nixos.tags = [ "niri" ];
      };
    in
    lib.mkIf (config.specialisation != { }) (
      lib.fold lib.recursiveUpdate otherConfig (map (p: import p { pkgs = pkgs; }) modules)
    );
}
