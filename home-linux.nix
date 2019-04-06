{ pkgs, ... }:

{
  home.packages = [
    pkgs.alacritty
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
    ./programs/i3.nix
    ./programs/i3status/default.nix
    ./programs/rofi.nix
    ./programs/neovim/default.nix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
