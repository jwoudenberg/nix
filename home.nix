{ pkgs, ... }:

{
  home.packages = [
    pkgs.git
  ];

  programs.home-manager = {
    enable = true;
    path = "https://github.com/rycee/home-manager/archive/release-18.09.tar.gz";
  };

  programs.git = {
    enable = true;
    userName = "Jasper Woudenberg";
    userEmail = "mail@jasperwoudenberg.com";
  };
}
