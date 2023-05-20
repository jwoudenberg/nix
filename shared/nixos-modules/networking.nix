{ pkgs, config, ... }: {
  networking.useNetworkd = true;
  systemd.network.wait-online = { anyInterface = true; };

  networking.wireless.iwd = {
    settings.General = {
      EnableNetworkConfiguration = true;
      AddressRandomization = "once";
    };
    enable = true;
  };

  services.resolved.enable = true;

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  services.tailscale.enable = true;
  systemd.services.tailscaled.after =
    [ "systemd-networkd-wait-online.service" ];

  fileSystems."/var/lib/tailscale" = {
    device = "/persist/tailscale";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
  };

  fileSystems."/var/lib/iwd" = {
    device = "/persist/iwd";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
  };
}
