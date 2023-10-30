{ pkgs, ... }:

{
  home.packages = [ pkgs.whipper ];
  home.file.".config/whipper/whipper.conf".source = ./whipper.conf;
}
