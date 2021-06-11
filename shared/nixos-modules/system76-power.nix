{ config, lib, pkgs, ... }:

{
  services.dbus.packages = [ pkgs.system76-power ];

  systemd.services.system76-power = {
    description = "System76 Power Daemon";
    serviceConfig = {
      ExecStart = "${pkgs.system76-power}/bin/system76-power daemon";
      Restart = "on-failure";
      Type = "dbus";
      BusName = "com.system76.PowerDaemon";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
