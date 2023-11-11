{ pkgs, ... }: {
  fileSystems."/var/lib/private/gonic" = {
    device = "/persist/gonic";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
    neededForBoot = true;
  };

  services.gonic = {
    enable = true;
    settings = {
      music-path = [ "/persist/music" ];
      listen-addr = "127.0.0.1:4553";
      proxy-prefix = "/music";
      podcast-path = "/var/lib/gonic/podcasts";
    };
  };
  systemd.services.gonic.serviceConfig.SupplementaryGroups = [ "music" ];
}
