{ pkgs, ... }:
{
  fileSystems."/var/lib/private/gonic" = {
    device = "/persist/gonic";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
    neededForBoot = true;
  };

  fileSystems."/home/jasper/music" = {
    device = "/persist/music";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
    neededForBoot = false;
  };

  services.gonic = {
    enable = true;
    settings = {
      music-path = [ "/persist/music" ];
      playlists-path = "/persist/music/00_playlists";
      listen-addr = "127.0.0.1:4553";
      proxy-prefix = "/music";
      # podcast-path is required by the nixos module, though I don't use it.
      podcast-path = "/var/lib/gonic/podcasts";
    };
  };
  systemd.services.gonic.serviceConfig.BindPaths = [ "/persist/music/00_playlists" ];
}
