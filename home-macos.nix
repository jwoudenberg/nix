{ pkgs, ... }:
{
  home.packages = [
    pkgs.nix-prefetch-github
    pkgs.ripgrep
    (pkgs.callPackage ./pkgs/gnupg.nix { })
    (pkgs.callPackage ./pkgs/pass.nix { })
    (pkgs.callPackage ./pkgs/lorri.nix { })
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
