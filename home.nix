{ pkgs, ... }:

{
  home.packages = [
    pkgs.alacritty
    pkgs.feh
    pkgs.fish
    pkgs.fzf
    pkgs.git
    pkgs.i3
    pkgs.i3status
    pkgs.ripgrep
    pkgs.rofi
  ];

  imports = [
    ./programs/fish/default.nix
    ./programs/fzf.nix
    ./programs/git.nix
    ./programs/home-manager.nix
    ./programs/i3.nix
    ./programs/rofi.nix
  ];
}
