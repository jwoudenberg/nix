{ pkgs, ... }:

{
  home.packages = [
    pkgs.comma
    pkgs.croc
    pkgs.gotop
    pkgs.jq
    pkgs.mosh
    pkgs.remind
    pkgs.nixfmt
    pkgs.pdfgrep
    pkgs.pijul
    pkgs.pulsemixer
    pkgs.random-colors
    pkgs.rem2html
    pkgs.shellcheck
    pkgs.signal-desktop
    pkgs.shy
    pkgs.perlPackages.vidir
    pkgs.visidata
    pkgs.wally-cli
    pkgs.wl-clipboard
    pkgs.xdg_utils
  ];

  programs.kitty.settings.font_size = 15;

  imports = [
    ../shared/home-manager-modules/aerc.nix
    ../shared/home-manager-modules/brightness.nix
    ../shared/home-manager-modules/direnv.nix
    ../shared/home-manager-modules/fish/default.nix
    ../shared/home-manager-modules/fzf.nix
    ../shared/home-manager-modules/git.nix
    ../shared/home-manager-modules/imv.nix
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
    ../shared/home-manager-modules/zathura.nix
  ];

  programs.ssh.userKnownHostsFile = "/persist/ssh/known_hosts";

  xdg.configFile."nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';

  xdg.mimeApps.enable = true;
}
