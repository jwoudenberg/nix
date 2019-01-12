{ pkgs, ... }:

{
  home.packages = [
    pkgs.fish
    pkgs.fzf
    pkgs.git
    pkgs.ripgrep
    pkgs.rofi
  ];

  imports = [
    ./programs/fish/default.nix
    ./programs/fzf.nix
    ./programs/git.nix
    ./programs/home-manager.nix
    ./programs/rofi.nix
  ];
}
