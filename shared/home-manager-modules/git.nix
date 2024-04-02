{ pkgs, ... }: {
  programs.git = {
    enable = true;
    userName = "Jasper Woudenberg";
    userEmail = "mail@jasperwoudenberg.com";

    lfs.enable = true;

    ignores = [ "todo.txt" ".direnv" ".lvimrc" "Session.vim" ];

    hooks.post-checkout = let
      script = pkgs.writeScriptBin "post-checkout"
        "${pkgs.random-colors}/bin/random-colors &";
    in "${script}/bin/post-checkout";

    extraConfig = {
      core.pager = "${pkgs.gitAndTools.delta}/bin/delta";
      branch.sort = "-committerdate";
      pull.rebase = false;
      init.defaultBranch = "main";
      push.useForceIfIncludes = true;
    };
  };
}
