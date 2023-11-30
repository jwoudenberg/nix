{ linuxCustomPkgs, pkgs, ... }:

{
  home.packages = [
    pkgs.agenda-txt
    pkgs.comma
    pkgs.croc
    pkgs.gotop
    pkgs.home-manager
    pkgs.nixpkgs-fmt
    pkgs.openvpn3
    pkgs.pdfgrep
    pkgs.random-colors
    pkgs.shellcheck
    pkgs.similar-sort
    pkgs.perlPackages.vidir
    pkgs.visidata
    pkgs.wally-cli
    pkgs.xclip
    pkgs.xdg_utils
  ];

  imports = [
    ../shared/home-manager-modules/aerc.nix
    ../shared/home-manager-modules/direnv.nix
    ../shared/home-manager-modules/fzf.nix
    ../shared/home-manager-modules/git.nix
    ../shared/home-manager-modules/keepassxc.nix
    ../shared/home-manager-modules/keepassxc-pass-frontend.nix
    ../shared/home-manager-modules/kitty.nix
    ../shared/home-manager-modules/neovim/default.nix
    ../shared/home-manager-modules/nix-index.nix
    ../shared/home-manager-modules/nushell/default.nix
    ../shared/home-manager-modules/procfile/default.nix
    ../shared/home-manager-modules/qrcode.nix
    ../shared/home-manager-modules/readline.nix
    ../shared/home-manager-modules/ripgrep.nix
    ../shared/home-manager-modules/ssh.nix
    ../shared/home-manager-modules/usb-scripts/default.nix
    ../shared/home-manager-modules/vale.nix
    ../shared/home-manager-modules/yubikey-agent.nix
  ];

  xdg.configFile."nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';

  nixpkgs.overlays = [ linuxCustomPkgs ];

  home.username = "jasper";
  home.homeDirectory = "/home/jasper";
  home.stateVersion = "23.11";
}
