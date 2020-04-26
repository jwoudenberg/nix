{ pkgs, ... }: {
  home.packages = [
    pkgs.cachix
    pkgs.gnupg
    pkgs.nix-prefetch-github
    pkgs.pass
    # Disabled because of security vulnerabilities in `xpdf`
    # pkgs.pdfrg
    pkgs.magic-wormhole
    pkgs.haskellPackages.niv
    pkgs.nixfmt
    pkgs.nodePackages.prettier
    pkgs.random-colors
    pkgs.ripgrep
    pkgs.shellcheck
    pkgs.similar-sort
    pkgs.todo
    pkgs.vale
  ];

  imports = [
    ../programs/alacritty.nix
    ../programs/direnv.nix
    ../programs/fish/default.nix
    ../programs/fzf.nix
    ../programs/git.nix
    ../programs/neovim/default.nix
    ../programs/qutebrowser/default.nix
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

  nixpkgs = import ../config.nix;

  home.stateVersion = "20.03";
}
