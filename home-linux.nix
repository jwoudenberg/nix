{ pkgs, ... }:

{
  home.packages = [
    pkgs.alacritty
    pkgs.direnv
    pkgs.feh
    pkgs.fish
    pkgs.fzf
    pkgs.git
    pkgs.i3
    pkgs.i3status
    pkgs.nix-prefetch-github
    pkgs.ripgrep
    pkgs.rofi
  ];

  imports = [
    ./programs/direnv.nix
    ./programs/fish/default.nix
    ./programs/fzf.nix
    ./programs/git.nix
    ./programs/home-manager.nix
    ./programs/i3.nix
    ./programs/i3status/default.nix
    ./programs/rofi.nix
    ./programs/neovim/default.nix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
