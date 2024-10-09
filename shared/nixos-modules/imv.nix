{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.imv ];

  xdg.mime.defaultApplications = {
    "image/bmp" = [ "imv.desktop" ];
    "image/gif" = [ "imv.desktop" ];
    "image/jpeg" = [ "imv.desktop" ];
    "image/jpg" = [ "imv.desktop" ];
    "image/png" = [ "imv.desktop" ];
    "image/tiff" = [ "imv.desktop" ];
  };
}
