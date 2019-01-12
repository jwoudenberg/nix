{ pkgs, ... }:

{
  home.packages = [
    pkgs.fish
    pkgs.fzf
    pkgs.git
    pkgs.ripgrep
    pkgs.rofi
  ];

  programs.home-manager = {
    enable = true;
    path = "https://github.com/rycee/home-manager/archive/release-18.09.tar.gz";
  };

  programs.fish = import ./programs/fish/default.nix;

  programs.fzf = {
    enable = true;
    defaultCommand = "rg --files";
  };

  programs.git = {
    enable = true;
    userName = "Jasper Woudenberg";
    userEmail = "mail@jasperwoudenberg.com";
  };

  programs.rofi = {
    enable = true;
    font = "FiraCode 14";
  };
}
