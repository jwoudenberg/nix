{ pkgs, ... }: {
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "rsyncnet" = {
        hostname = "ch-s012.rsync.net";
        user = "19438";
      };
    };
  };
}
