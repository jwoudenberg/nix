{ pkgs, ... }: {
  home.file.i3status = {
    target = ".config/i3status/config";
    source = ./config;
  };
}
