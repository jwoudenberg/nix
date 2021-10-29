{ pkgs, ... }: {
  programs.ssh = {
    enable = true;
    userKnownHostsFile = "/persist/ssh/known_hosts";
    matchBlocks = {
      "ai-banana" = { user = "root"; };
      "rsyncnet" = {
        hostname = "ch-s012.rsync.net";
        user = "19438";
      };
    };
  };
}
