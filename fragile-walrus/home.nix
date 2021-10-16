{ pkgs, ... }:

let

  boot-popos = pkgs.writeShellScriptBin "popos" ''
    #!/usr/bin/env bash
    set -euxo pipefail

    bootctl set-oneshot Pop_OS-current.conf
    systemctl reboot
  '';

in {
  home.packages = [
    boot-popos
    pkgs.cachix
    pkgs.chromium
    pkgs.discord
    pkgs.du-dust
    pkgs.fd
    pkgs.gnupg
    pkgs.gotop
    pkgs.grim
    pkgs.i3status
    pkgs.imv
    pkgs.jq
    pkgs.keybase
    pkgs.magic-wormhole
    pkgs.mosh
    pkgs.zathura
    pkgs.haskellPackages.niv
    pkgs.minecraft
    pkgs.nixfmt
    pkgs.nix-prefetch-github
    pkgs.nodePackages.prettier
    pkgs.pdfgrep
    pkgs.pulsemixer
    pkgs.plex-media-player
    pkgs.podman
    pkgs.random-colors
    pkgs.ripgrep
    pkgs.sd
    pkgs.shellcheck
    pkgs.similar-sort
    pkgs.slurp
    pkgs.tabnine
    pkgs.tmate
    pkgs.vale
    pkgs.wally-cli
    pkgs.wl-clipboard
    pkgs.xdg_utils
    pkgs.zoom-us
  ];

  imports = [
    ../shared/home-manager-modules/direnv.nix
    ../shared/home-manager-modules/qutebrowser.nix
    ../shared/home-manager-modules/fish/default.nix
    ../shared/home-manager-modules/fzf.nix
    ../shared/home-manager-modules/git.nix
    ../shared/home-manager-modules/i3status/default.nix
    ../shared/home-manager-modules/kitty.nix
    ../shared/home-manager-modules/neovim/default.nix
    ../shared/home-manager-modules/pass.nix
    ../shared/home-manager-modules/qutebrowser.nix
    ../shared/home-manager-modules/readline.nix
    ../shared/home-manager-modules/ripgrep.nix
    ../shared/home-manager-modules/ssh.nix
    ../shared/home-manager-modules/sway.nix
    ../shared/home-manager-modules/take-screenshot.nix
    ../shared/home-manager-modules/vale/default.nix
    ../shared/home-manager-modules/wlsunset.nix
  ];

  programs.kitty.settings.font_size = 14;

  home.sessionVariables = {
    EDITOR = "nvim";
    DEFAULT_TODO_TXT = "~/docs/todo.txt";
    MANPAGER = "nvim -c 'set ft=man' -";
    AWS_VAULT_BACKEND = "file";
    # Fix issue with opening links in Firefox using :GBrowse.
    MOZ_DBUS_REMOTE = "1";
  };

  home.stateVersion = "21.05";

  xdg.configFile."nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];
      "x-www-browser" = [ "qutebrowser.desktop" ];
      "x-scheme-handler/http" = [ "qutebrowser.desktop" ];
      "x-scheme-handler/https" = [ "qutebrowser.desktop" ];
      "image/bmp" = [ "imv.desktop" ];
      "image/gif" = [ "imv.desktop" ];
      "image/jpeg" = [ "imv.desktop" ];
      "image/jpg" = [ "imv.desktop" ];
      "image/png" = [ "imv.desktop" ];
      "image/tiff" = [ "imv.desktop" ];
    };
  };
}
