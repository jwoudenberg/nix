{ pkgs, ... }: {
  programs.git = {
    enable = true;
    userName = "Jasper Woudenberg";
    userEmail = "mail@jasperwoudenberg.com";

    lfs.enable = true;

    ignores = [ "todo.txt" ".direnv" ".lvimrc" "Session.vim" ];

    extraConfig = {
      core.pager = "${pkgs.gitAndTools.delta}/bin/delta";
      branch.sort = "-committerdate";
      pull.rebase = false;
      init.defaultBranch = "main";
    };
  };
}
