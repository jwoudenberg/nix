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

  systemd.tmpfiles.rules = [
    "d /persist 0700 root root - -"

    "d /home/jasper/.config 0700 jasper users - -"
    "d /home/jasper/.cache 0700 jasper users - -"
    "d /home/jasper/.local 0700 jasper users - -"
    "d /home/jasper/.local/share 0700 jasper users - -"
  ];
}
