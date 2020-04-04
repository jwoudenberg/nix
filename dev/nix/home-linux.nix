{ pkgs, ... }:

{
  home.packages = [
    pkgs.cachix
    pkgs.calibre
    pkgs.firefox-wayland
    pkgs.gnupg
    pkgs.grim
    pkgs.htop
    pkgs.i3status
    pkgs.imv
    pkgs.keybase
    pkgs.magic-wormhole
    pkgs.nixfmt
    pkgs.nix-prefetch-github
    pkgs.nodePackages.prettier
    pkgs.pass
    pkgs.pavucontrol
    pkgs.pdfrg
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
    ./programs/alacritty.nix
    ./programs/direnv.nix
    ./programs/fish/default.nix
    ./programs/fzf.nix
    ./programs/git.nix
    ./programs/i3status/default.nix
    ./programs/neovim/default.nix
    ./programs/sway.nix
    ./programs/vale/default.nix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    DEFAULT_TODO_TXT = "~/docs/todo.txt";
  };

  home.stateVersion = "19.09";

  nixpkgs.config = import ./nixpkgs-config.nix;

  nixpkgs.overlays = [
    (import ./overlays/gnupg.nix)
    (import ./overlays/nixfmt.nix)
    (import ./overlays/pass.nix)
    (import ./overlays/pdfrg.nix)
    (import ./overlays/pinentry.nix)
    (import ./overlays/random-colors.nix)
    (import ./overlays/similar-sort.nix)
    (import ./overlays/todo.nix)
    (import ./overlays/wofi.nix)
  ];
}
