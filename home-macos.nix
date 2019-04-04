{ pkgs, ... }:

{
  home.packages = [
    pkgs.fish
    pkgs.fzf
    pkgs.git
    pkgs.nix-prefetch-github
    pkgs.ripgrep
  ];

  imports = [
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
