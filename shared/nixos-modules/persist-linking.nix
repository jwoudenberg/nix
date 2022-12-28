{ pkgs, ... }: {
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
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -euxo pipefail

      # chown directories in home we're bind-mounting into
      mkdir -p /home/jasper/{.config,.cache}
      chown jasper:users /home/jasper/{.config,.cache}
    '';
  };
}
