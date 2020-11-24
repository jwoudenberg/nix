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
      # interactive.diffFilter =
      #   "${pkgs.gitAndTools.delta}/bin/delta --color-only";
      branch.sort = "-committerdate";
      pull.rebase = false;
    };
  };
}
