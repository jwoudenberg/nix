{ pkgs, config, lib, ... }:

{
  config =
    let
      modules = [ ../shared/nixos-modules/sway.nix ];
      otherConfig = {
        system.nixos.tags = [ "sway" ];

        programs.firefox = {
          enable = true;
        };

        fileSystems."/home/jasper/.mozilla" = {
          device = "/persist/mozilla";
          fsType = "none";
          options = [ "bind" ];
          depends = [ "/persist" ];
        };

        fileSystems."/home/jasper/work" = {
          device = "/persist/work";
          fsType = "none";
          options = [ "bind" ];
          depends = [ "/persist" ];
        };
      };
    in
    lib.mkIf (config.specialisation != { })
      (lib.fold lib.recursiveUpdate otherConfig
        (map (p: import p { pkgs = pkgs; }) modules));
}
