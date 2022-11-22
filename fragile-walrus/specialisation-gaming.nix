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

  services.xserver.desktopManager.gnome.enable = true;

  programs.steam.enable = true;
  systemd.services.persist-linking-steam = {
    description = "Create symbolic links for Steam to /persist";
    after = [ "persist.mount" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -euxo pipefail

      ln -sfn /persist/steam/games /home/jasper/.steam

      mkdir -p /home/jasper/.local/share
      chown -R jasper:users /home/jasper/.local/share
      ln -sfn /persist/steam/install /home/jasper/.local/share/Steam
    '';
  };

  # Without this system76-power will exit shortly after it is started.
  services.power-profiles-daemon.enable = false;
}
