{ pkgs, ... }: {
  home.packages = [
    pkgs.cachix
    pkgs.comma
    pkgs.du-dust
    pkgs.fd
    pkgs.gitAndTools.gh
    pkgs.gnupg
    pkgs.gotop
    pkgs.nix-prefetch-github
    pkgs.pass
    pkgs.pdfgrep
    pkgs.magic-wormhole
    pkgs.haskellPackages.niv
    pkgs.jq
    pkgs.tabnine
    pkgs.mosh
    pkgs.nixfmt
    pkgs.nix-script
    pkgs.nodePackages.prettier
    pkgs.random-colors
    pkgs.ripgrep
    pkgs.sd
    pkgs.shellcheck
    pkgs.similar-sort
    pkgs.todo
    pkgs.vale
  ];

  imports = [
    ../programs/direnv.nix
    ../programs/fish/default.nix
    ../programs/fzf.nix
    ../programs/git.nix
    ../programs/kitty.nix
    ../programs/neovim/default.nix
    ../programs/ripgrep.nix
    ../programs/readline.nix
    ../programs/vale/default.nix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    DEFAULT_TODO_TXT = "~/docs/todo.txt";
    SSL_CERT_FILE = "/usr/local/etc/openssl/cert.pem";
    MANPAGER = "nvim -c 'set ft=man' -";
  };

  home.stateVersion = "20.03";
}
