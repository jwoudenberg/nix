{ pkgs, ... }: {
  home.packages = [ pkgs.imv ];

  xdg.mimeApps.defaultApplications = {
    "image/bmp" = [ "imv.desktop" ];
    "image/gif" = [ "imv.desktop" ];
    "image/jpeg" = [ "imv.desktop" ];
    "image/jpg" = [ "imv.desktop" ];
    "image/png" = [ "imv.desktop" ];
    "image/tiff" = [ "imv.desktop" ];
  };
}
