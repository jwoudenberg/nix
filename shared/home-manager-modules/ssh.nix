{ pkgs, ... }: {
  programs.ssh = {
    enable = true;
    compression = true; # Needed by tmate
    matchBlocks = {
      "ai-banana" = { user = "root"; };
      "worst-chocolate" = { user = "root"; };
    };
  };
}
