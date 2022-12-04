{ pkgs, config, ... }: {
  networking.useNetworkd = true;
  systemd.network.wait-online = { anyInterface = true; };

  networking.wireless.iwd.enable = true;

  services.resolved.enable = true;

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  services.tailscale.enable = true;
  systemd.services.tailscaled.after =
    [ "systemd-networkd-wait-online.service" ];

  systemd.services.networking-persist-linking = {
    description = "Mount networking dirs from /persist";
    after = [ "persist.mount" ];
    wantedBy = [ "iwd.service" "tailscaled.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -euxo pipefail

      mkdir -p /persist/iwd /var/lib/tailscale
      ${pkgs.mount}/bin/mount --bind /persist/iwd /var/lib/iwd
      ${pkgs.mount}/bin/mount --bind /persist/tailscale /var/lib/tailscale
    '';
  };
}
