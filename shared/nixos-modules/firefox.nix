{ pkgs, ... }: {
  programs.firefox = {
    enable = true;
  };

  fileSystems."/home/jasper/.mozilla" = {
    device = "/persist/mozilla";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
  };
}
