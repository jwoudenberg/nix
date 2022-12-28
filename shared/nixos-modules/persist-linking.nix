{ pkgs, ... }: {
  fileSystems."/home/jasper/docs" = {
    device = "/persist/rslsync/jasper";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
  };

  fileSystems."/home/jasper/hjgames" = {
    device = "/persist/rslsync/hjgames";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
  };

  fileSystems."/home/jasper/dev" = {
    device = "/persist/dev";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
  };

  fileSystems."/home/jasper/.config/random-colors" = {
    device = "/persist/random-colors";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
  };

  fileSystems."/home/jasper/.config/Signal" = {
    device = "/persist/signal";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
  };

  fileSystems."/home/jasper/.config/pijul" = {
    device = "/persist/pijul";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
  };

  fileSystems."/home/jasper/.cache/nix-index" = {
    device = "/persist/nix-index";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
  };

  systemd.services.persist-permissions = {
    description = "Set correct permissions for bind mounts to /persist";
    wantedBy = [ "multi-user.target" "resilio.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -euxo pipefail

      # Make /persist public so the rslsync user can look in it.
      chmod 755 /persist

      # chown directories in home we're bind-mounting into
      mkdir -p /home/jasper/{.config,.cache}
      chown jasper:users /home/jasper/{.config,.cache}

      # Set permissions for rslsync dirs (these gets reset sometimes, don't know why)
      chown -R rslsync:rslsync /persist/rslsync
      chmod -R 770 /persist/rslsync
    '';
  };
}
