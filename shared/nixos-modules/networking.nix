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
    description = "Create symbolic links to /persist";
    after = [ "persist.mount" ];
    wantedBy = [ "iwd.service" "tailscaled.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -euxo pipefail


      # Iwd wifi passwords
      mkdir -p /persist/iwd
      for file in /persist/iwd/*.psk; do
        ln -sfn "$file" "/var/lib/iwd/$(basename "$file")"
      done

      # Tailscale state
      mkdir -p /var/lib/tailscale
      ln -sfn /persist/tailscale/files /var/lib/tailscale/files
      ln -sfn /persist/tailscale/tailscaled.log.conf /var/lib/tailscale/tailscaled.log.conf
    '';
  };
}
