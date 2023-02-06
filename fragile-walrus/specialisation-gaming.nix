{ pkgs, ... }: {
  services.xserver.enable = true;
  services.xserver.desktopManager.lxqt.enable = true;
  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "jasper";
  };

  fileSystems."/home/jasper/.steam" = {
    device = "/persist/steam/games";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
  };

  fileSystems."/home/jasper/.local/share/Steam" = {
    device = "/persist/steam/install";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
  };

  programs.steam.enable = true;
}
