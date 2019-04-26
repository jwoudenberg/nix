{ pkgs, ... }:
{
  home.packages = [
    pkgs.gnupg
    pkgs.lorri
    pkgs.nix-prefetch-github
    pkgs.pass
    pkgs.nodePackages.prettier
    pkgs.random-colors
    pkgs.ripgrep
    pkgs.shellcheck
    pkgs.vale
  ];

  imports = [
    ./programs/direnv.nix
    ./programs/fish/default.nix
    ./programs/fzf.nix
    ./programs/git.nix
    ./programs/home-manager.nix
    ./programs/neovim/default.nix
    ./programs/vale/default.nix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    SSL_CERT_FILE = "/usr/local/etc/openssl/cert.pem";
  };
}
