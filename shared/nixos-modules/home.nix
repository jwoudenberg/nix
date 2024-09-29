{ pkgs, ... }:
let
  home = pkgs.runCommand "home" { } ''
    mkdir -p "$out/.config/nvim/spell"
    ln -s "${../home-manager-modules/neovim/init.lua}" "$out/.config/nvim/init.lua"
    ln -s "${pkgs.vim-spell-nl}" "$out/.config/nvim/spell/nl.utf-8.spl"
  '';
in
{
  fileSystems."/home/test" = {
    fsType = "overlay";
    options = [ "volatile" ];
    overlay = {
      lowerdir = [ "${home}" ];
      upperdir = "/tmp/home-upper";
      workdir = "/tmp/home-work";
    };
  };

  systemd.tmpfiles.rules = [
    "z /home/test 0700 jasper users - -"
    "z /tmp/home-upper 0700 jasper users - -"
    "z /tmp/home-work 0700 jasper users - -"
  ];
}
