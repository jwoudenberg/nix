{ pkgs, config, ... }:
{
  homedir.files = {
    ".config/git/ignore" = pkgs.writeText "ignore" ''
      todo.txt
      .direnv
      .lvimrc
      Session.vim
    '';

    ".config/git/config" = pkgs.writeText "config" (
      pkgs.lib.generators.toINI { } {
        branch = {
          sort = "-committerdate";
        };

        commit = {
          gpgsign = true;
        };

        core = {
          hooksPath =
            let
              script = pkgs.writeScriptBin "post-checkout" "${pkgs.random-colors}/bin/random-colors &";
            in
            "${script}/bin/post-checkout";
          pager = "${pkgs.delta}/bin/delta";
        };

        "filter \"lfs\"" = {
          clean = "git-lfs clean -- %f";
          process = "git-lfs filter-process";
          required = true;
          smudge = "git-lfs smudge -- %f";
        };

        gpg = {
          format = "ssh";
        };

        init = {
          defaultBranch = "main";
        };

        pull = {
          rebase = false;
        };

        push = {
          useForceIfIncludes = true;
        };

        user = {
          email = "mail@jasperwoudenberg.com";
          name = "Jasper Woudenberg";
          signingkey = "key::sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAICX1KxUJWwIscXsNGnb778Q/nhbg8ir8K0iXZFDsQEzkAAAADnNzaDpZdWJpa2V5U1NI jasper@sentient-tshirt";
        };
      }
    );
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
  };
}
