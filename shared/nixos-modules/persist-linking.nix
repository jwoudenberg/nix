{ pkgs, ... }: {
  systemd.services.persist-linking = {
    description = "Create symbolic links to /persist";
    after = [ "persist.mount" ];
    wantedBy = [ "multi-user.target" "resilio.service" ];
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

      # Set permissions for rslsync dirs (these gets reset sometimes, don't know why)
      chown -R rslsync:rslsync /persist/rslsync
      chmod -R 770 /persist/rslsync
    '';
  };
}
