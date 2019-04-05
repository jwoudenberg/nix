{ pkgs, ... }:

{
  home.packages = [
    pkgs.gitAndTools.diff-so-fancy
    pkgs.direnv
    pkgs.fish
    pkgs.fzf
    pkgs.git
    pkgs.nix-prefetch-github
    pkgs.ripgrep
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
