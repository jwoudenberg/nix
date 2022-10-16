{ pkgs, ... }: {
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" ];
  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  systemd.services.persist-linking = {
    description = "Create symbolic links to /persist";
    after = [ "persist.mount" ];
    wantedBy = [ "multi-user.target" "tailscaled.service" "resilio.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -euxo pipefail

      # Make /persist public so the rslsync user can look in it.
      chmod 755 /persist

      # Symbolic links to home directory.
      ln -sfn /persist/rslsync/jasper /home/jasper/docs
      ln -sfn /persist/rslsync/hjgames /home/jasper/hjgames
      ln -sfn /persist/dev /home/jasper/dev

      mkdir -p /home/jasper/.config
      chown jasper:users /home/jasper/.config
      ln -sfn /persist/random-colors /home/jasper/.config/random-colors
      ln -sfn /persist/signal /home/jasper/.config/Signal
      ln -sfn /persist/pijul /home/jasper/.config/pijul

      mkdir -p /home/jasper/.cache
      chown jasper:users /home/jasper/.cache
      ln -sfn /persist/nix-index /home/jasper/.cache/nix-index

      # Tailscale state
      mkdir -p /var/lib/tailscale
      ln -sfn /persist/tailscale/files /var/lib/tailscale/files
      ln -sfn /persist/tailscale/tailscaled.state /var/lib/tailscale/tailscaled.state
      ln -sfn /persist/tailscale/tailscaled.log.conf /var/lib/tailscale/tailscaled.log.conf

      # Set permissions for rslsync dirs (these gets reset sometimes, don't know why)
      chown -R rslsync:rslsync /persist/rslsync
      chmod -R 770 /persist/rslsync
    '';
  };
}
