{ pkgs, ... }: {
  programs.ssh = {
    enable = true;
    compression = true; # Needed by tmate
  };
}
