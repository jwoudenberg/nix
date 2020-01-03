# Setup on MacOS:
#
# Create the following symbolic links:
# ~/.config/nixpkgs/home.nix -> home-macos.nix
# ~/.config/nixpkgs/overlays -> overlays
#
# Then follow home-manager setup instructions like normal.
{ pkgs, ... }: {
  home.packages = [
    pkgs.cachix
    pkgs.gnupg
    pkgs.lorri
    pkgs.nix-prefetch-github
    pkgs.pass
    pkgs.pdfrg
    pkgs.magic-wormhole
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
    ./programs/direnv.nix
    ./programs/fish/default.nix
    ./programs/fzf.nix
    ./programs/git.nix
    ./programs/home-manager.nix
    ./programs/lorri-daemon.nix
    ./programs/neovim/default.nix
    # Not supported yet in current stable version of home-manager.
    # ./programs/readline.nix
    ./programs/vale/default.nix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    DEFAULT_TODO_TXT = "~/docs/todo.txt";
    SSL_CERT_FILE = "/usr/local/etc/openssl/cert.pem";
  };
}
