{
  pkgs,
  config,
  lib,
  ...
}:

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
          device = "/persist/work/.mozilla";
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

        services.openvpn.servers.work = {
          config = "config /home/jasper/work/config.ovpn";
          autoStart = false;
        };
        services.openvpn.servers.work-breakglass = {
          config = "config /home/jasper/work/config.breakglass.ovpn";
          autoStart = false;
        };

        programs.update-systemd-resolved.servers.work.includeAutomatically = true;

        # For android-studio
        programs.xwayland.enable = true;
      };
    in
    lib.mkIf (config.specialisation != { }) (
      lib.fold lib.recursiveUpdate otherConfig (map (p: import p { pkgs = pkgs; }) modules)
    );
}
