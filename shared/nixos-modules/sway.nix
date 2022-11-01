{ pkgs, ... }: {
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  programs.sway.enable = true;
  programs.xwayland.enable = false;
  fonts.fonts = [ pkgs.fira-code ];

  services.greetd = {
    enable = true;
    vt = 2;
    settings = {
      # Automatically login. I already entered a password to unlock the disk.
      initial_session = {
        command = "sway";
        user = "jasper";
      };
      default_session = {
        command =
          "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --greeting 'Hoi!' --cmd sway";
        user = "jasper";
      };
    };
  };
  # To avoid interleaving tuigreet output with booting output:
  # https://github.com/apognu/tuigreet/issues/17
  systemd.services.greetd.serviceConfig.Type = "idle";

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };

  # Enable wayland for Chrome and Electron apps.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
