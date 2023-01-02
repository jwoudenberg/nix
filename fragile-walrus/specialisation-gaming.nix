{ pkgs, ... }: {
  services.xserver.enable = true;

  services.xserver.displayManager.gdm = {
    enable = true;
    autoSuspend = false;
  };
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

  services.xserver.desktopManager.gnome.enable = true;

  programs.steam.enable = true;

  # Without this system76-power will exit shortly after it is started.
  services.power-profiles-daemon.enable = false;
}
