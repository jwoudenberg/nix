{ pkgs, ... }:

{
  home.packages = [
    pkgs.agenda-txt
    pkgs.annotator
    pkgs.ics-to-agenda-txt
    pkgs.comma
    pkgs.cooklang
    pkgs.croc
    pkgs.gotop
    pkgs.mosh
    pkgs.nixfmt-rfc-style
    pkgs.pdfgrep
    pkgs.pijul
    pkgs.pulsemixer
    pkgs.random-colors
    pkgs.shellcheck
    pkgs.signal-desktop
    pkgs.perlPackages.vidir
    pkgs.visidata
    pkgs.wl-clipboard
    pkgs.xdg_utils
  ];

  programs.kitty.settings.font_size = 15;

  imports = [
    ../shared/home-manager-modules/aerc.nix
    ../shared/home-manager-modules/git.nix
    ../shared/home-manager-modules/kitty.nix
    ../shared/home-manager-modules/neovim/default.nix
    ../shared/home-manager-modules/nushell/default.nix
    ../shared/home-manager-modules/procfile/default.nix
    ../shared/home-manager-modules/qrcode.nix
    ../shared/home-manager-modules/qutebrowser.nix
    ../shared/home-manager-modules/readline.nix
    ../shared/home-manager-modules/read-qrcode.nix
    ../shared/home-manager-modules/ripgrep.nix
    ../shared/home-manager-modules/ssh.nix
    ../shared/home-manager-modules/sway.nix
    ../shared/home-manager-modules/take-screenshot.nix
    ../shared/home-manager-modules/usb-scripts/default.nix
    ../shared/home-manager-modules/vale.nix
    ../shared/home-manager-modules/whipper/default.nix
    ../shared/home-manager-modules/wlsunset.nix
    ../shared/home-manager-modules/zathura.nix
    ../shared/home-manager-modules/zed.nix
  ];

  xdg.configFile."nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';

  xdg.mimeApps.enable = true;

  home.stateVersion = "24.05";
}
