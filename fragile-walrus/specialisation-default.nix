{
  pkgs,
  config,
  lib,
  ...
}:

{
  config =
    let
      modules = [ ../modules/sway.nix ];
      otherConfig = {
        system.nixos.tags = [ "sway" ];
      };
    in
    lib.mkIf (config.specialisation != { }) (
      lib.fold lib.recursiveUpdate otherConfig (map (p: import p { pkgs = pkgs; }) modules)
    );
}
