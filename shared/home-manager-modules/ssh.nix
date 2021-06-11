{ pkgs, ... }: {
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "ai-banana" = {
        hostname = "ai-banana.jasperwoudenberg.com";
        user = "root";
      };
      "rsyncnet" = {
        hostname = "ch-s012.rsync.net";
        user = "19438";
      };
    };
  };
}
