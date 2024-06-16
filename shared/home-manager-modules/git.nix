{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "Jasper Woudenberg";
    userEmail = "mail@jasperwoudenberg.com";

    lfs.enable = true;

    ignores = [
      "todo.txt"
      ".direnv"
      ".lvimrc"
      "Session.vim"
    ];

    hooks.post-checkout =
      let
        script = pkgs.writeScriptBin "post-checkout" "${pkgs.random-colors}/bin/random-colors &";
      in
      "${script}/bin/post-checkout";

    extraConfig = {
      core.pager = "${pkgs.gitAndTools.delta}/bin/delta";
      branch.sort = "-committerdate";
      pull.rebase = false;
      init.defaultBranch = "main";
      push.useForceIfIncludes = true;
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "key::sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAICX1KxUJWwIscXsNGnb778Q/nhbg8ir8K0iXZFDsQEzkAAAADnNzaDpZdWJpa2V5U1NI jasper@sentient-tshirt";
    };
  };
}
