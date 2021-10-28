{ pkgs, ... }: {
  programs.git = {
    enable = true;
    userName = "Jasper Woudenberg";
    userEmail = "mail@jasperwoudenberg.com";

    lfs.enable = true;

    ignores = [ "todo.txt" ".direnv" ".lvimrc" ];

    extraConfig = {
      core.pager = ''
        ${pkgs.gitAndTools.delta}/bin/delta --plus-color="#012800" --minus-color="#340001"'';
      branch.sort = "-committerdate";
      pull.rebase = false;
      init.defaultBranch = "main";
    };
  };
}
