{ pkgs, ... }:

{
  home.packages = [
    pkgs.comma
    pkgs.croc
    pkgs.discord
    pkgs.gotop
    pkgs.i3status
    pkgs.imv
    pkgs.jq
    pkgs.keybase
    pkgs.mosh
    pkgs.remind
    pkgs.zathura
    pkgs.haskellPackages.niv
    pkgs.minecraft
    pkgs.nixfmt
    pkgs.nix-prefetch-github
    pkgs.pdfgrep
    pkgs.pijul
    pkgs.pulsemixer
    pkgs.random-colors
    pkgs.rem2html
    pkgs.shellcheck
    pkgs.signal-desktop
    pkgs.similar-sort
    pkgs.shy
    pkgs.tabnine
    pkgs.perlPackages.vidir
    pkgs.visidata
    pkgs.wally-cli
    pkgs.wl-clipboard
    pkgs.xdg_utils
    pkgs.zoom-us
  ];

  imports = [
    ../shared/home-manager-modules/brightness.nix
    ../shared/home-manager-modules/direnv.nix
    ../shared/home-manager-modules/fish/default.nix
    ../shared/home-manager-modules/fzf.nix
    ../shared/home-manager-modules/git.nix
    ../shared/home-manager-modules/i3status/default.nix
    ../shared/home-manager-modules/keepassxc-pass-frontend.nix
    ../shared/home-manager-modules/kitty.nix
    ../shared/home-manager-modules/keepassxc.nix
    ../shared/home-manager-modules/make-screenrec.nix
    ../shared/home-manager-modules/neovim/default.nix
    ../shared/home-manager-modules/nix-index.nix
    ../shared/home-manager-modules/procfile/default.nix
    ../shared/home-manager-modules/qutebrowser.nix
    ../shared/home-manager-modules/readline.nix
    ../shared/home-manager-modules/ripgrep.nix
    ../shared/home-manager-modules/ssh.nix
    ../shared/home-manager-modules/sway.nix
    ../shared/home-manager-modules/take-screenshot.nix
    ../shared/home-manager-modules/vale.nix
    ../shared/home-manager-modules/wlsunset.nix
  ];

  programs.kitty.settings.font_size = 15;
  programs.ssh.userKnownHostsFile = "/persist/ssh/known_hosts";

  home.sessionVariables = {
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
  };

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
