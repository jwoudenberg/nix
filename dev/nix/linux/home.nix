{ pkgs, ... }:

{
  home.packages = [
    pkgs.cachix
    pkgs.calibre
    pkgs.gnupg
    pkgs.grim
    pkgs.htop
    pkgs.i3status
    pkgs.imv
    pkgs.keybase
    pkgs.magic-wormhole
    pkgs.haskellPackages.niv
    pkgs.nixfmt
    pkgs.nix-prefetch-github
    pkgs.nodePackages.prettier
    pkgs.pass
    pkgs.pavucontrol
    pkgs.pdfrg
    pkgs.qutebrowser
    pkgs.random-colors
    pkgs.ripgrep
    pkgs.shellcheck
    pkgs.similar-sort
    pkgs.slurp
    pkgs.todo
    pkgs.vale
    pkgs.wl-clipboard
    pkgs.wofi
    pkgs.xdg_utils
    pkgs.zoom-us
  ];

  imports = [
    ../programs/alacritty.nix
    ../programs/direnv.nix
    ../programs/firefox.nix
    ../programs/fish/default.nix
    ../programs/fzf.nix
    ../programs/git.nix
    ../programs/i3status/default.nix
    ../programs/neovim/default.nix
    ../programs/qutebrowser/default.nix
    ../programs/sway.nix
    ../programs/vale/default.nix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    DEFAULT_TODO_TXT = "~/docs/todo.txt";
    MANPAGER = "nvim -c 'set ft=man' -";
  };

  home.stateVersion = "19.09";

  nixpkgs.config = import ../nixpkgs-config.nix;

  nixpkgs.overlays = import ../overlays.nix;
}
