{ pkgs, ... }:
{
  home.packages = [
    pkgs.gnupg
    pkgs.lorri
    pkgs.nix-prefetch-github
    pkgs.pass
    pkgs.pdfrg
    pkgs.magic-wormhole
    pkgs.nodePackages.prettier
    pkgs.random-colors
    pkgs.ripgrep
    pkgs.shellcheck
    pkgs.todo
    pkgs.vale
  ];

  imports = [
    ./programs/direnv.nix
    ./programs/fish/default.nix
    ./programs/fzf.nix
    ./programs/git.nix
    ./programs/home-manager.nix
    ./programs/lorri-daemon.nix
    ./programs/neovim/default.nix
    ./programs/vale/default.nix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    DEFAULT_TODO_TXT = "~/docs/todo.txt";
    SSL_CERT_FILE = "/usr/local/etc/openssl/cert.pem";
  };
}
