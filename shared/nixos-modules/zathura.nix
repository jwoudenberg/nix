{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.zathura ];

  xdg.mime.defaultApplications."application/pdf" = [ "org.pwmt.zathura.desktop" ];
}
