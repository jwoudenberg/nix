{ pkgs, ... }: {
  programs.ssh = {
    enable = true;
    compression = true; # Needed by tmate
    matchBlocks = {
      "ai-banana" = { user = "root"; };
      "rsyncnet" = {
        hostname = "ch-s012.rsync.net";
        user = "19438";
      };
    };
  };
}
