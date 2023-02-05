{ pkgs, ... }: {
  services.xserver = {
    enable = true;
    libinput.enable = true;
  };

  services.xserver.displayManager = {
    session = [{
      manage = "desktop";
      name = "steam";
      start = ''
        ${pkgs.steam}/bin/steam -bigpicture &
        waitPID=$!
      '';
    }];
    defaultSession = "steam";
    autoLogin = {
      enable = true;
      user = "jasper";
    };
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
