{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "Jasper Woudenberg";
    userEmail = "mail@jasperwoudenberg.com";

    lfs.enable = true;

    extraConfig = {
      core.pager = "${pkgs.gitAndTools.diff-so-fancy}/bin/diff-so-fancy | less --tabs=4 -RFX";
    };
  };
}
