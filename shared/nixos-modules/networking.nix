{ pkgs, config, ... }: {
  networking.useNetworkd = true;
  systemd.network.wait-online = { anyInterface = true; };

  # # Not sure why, but iwd isn't working anymore as of latest home wifi setup.
  # # I'm hopeful to return to it in the future.
  #
  # networking.wireless.iwd = {
  #   settings.General = {
  #     EnableNetworkConfiguration = true;
  #     AddressRandomization = "once";
  #   };
  #   enable = true;
  # };
  # fileSystems."/var/lib/iwd" = {
  #   device = "/persist/iwd";
  #   fsType = "none";
  #   options = [ "bind" ];
  #   depends = [ "/persist" ];
  # };

  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;
  fileSystems."/etc/NetworkManager/system-connections" = {
    device = "/persist/networkmanager-connections";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
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
}
