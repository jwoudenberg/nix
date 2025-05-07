{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.ki-editor
    pkgs.nixfmt-rfc-style
  ];

  fileSystems."/home/jasper/.config/ki" = {
    device = "/persist/ki";
    fsType = "none";
    options = [ "bind" ];
    depends = [
      "/persist"
      "/home/jasper"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /persist/ki 0700 jasper users - -"
  ];

  homedir.sessionVariables = {
    EDITOR = "ki";
  };
}
