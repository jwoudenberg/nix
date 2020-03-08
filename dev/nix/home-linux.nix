{ pkgs, ... }:

{
  home.packages = [
    pkgs.cachix
    pkgs.gnupg
    pkgs.nix-prefetch-github
    pkgs.pass
    pkgs.pdfrg
    pkgs.magic-wormhole
    pkgs.nixfmt
    pkgs.nodePackages.prettier
    pkgs.random-colors
    pkgs.ripgrep
    pkgs.shellcheck
    pkgs.similar-sort
    pkgs.todo
    pkgs.vale
  ];

  imports = [
    ./programs/alacritty.nix
    ./programs/direnv.nix
    ./programs/fish/default.nix
    ./programs/fzf.nix
    ./programs/git.nix
    ./programs/home-manager.nix
    ./programs/i3.nix
    ./programs/i3status/default.nix
    ./programs/rofi.nix
    ./programs/neovim/default.nix
    ./programs/vale/default.nix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    DEFAULT_TODO_TXT = "~/docs/todo.txt";
  };

  nixpkgs.overlays = [
    (import ./overlays/gnupg.nix)
    (import ./overlays/nixfmt.nix)
    (import ./overlays/pass.nix)
    (import ./overlays/pdfrg.nix)
    (import ./overlays/pinentry.nix)
    (import ./overlays/random-colors.nix)
    (import ./overlays/similar-sort.nix)
    (import ./overlays/todo.nix)
  ];
}
