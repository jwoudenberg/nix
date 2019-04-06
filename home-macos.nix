{ pkgs, ... }:
{
  home.packages = [
    pkgs.gnupg
    pkgs.lorri
    pkgs.nix-prefetch-github
    pkgs.pass
    pkgs.ripgrep
    pkgs.shellcheck
  ];

  imports = [
    ./programs/direnv.nix
    ./programs/fish/default.nix
    ./programs/fzf.nix
    ./programs/git.nix
    ./programs/home-manager.nix
    ./programs/neovim/default.nix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
