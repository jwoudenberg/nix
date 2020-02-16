{ pkgs, ... }:

{
  home.packages = [
    pkgs.alacritty
    pkgs.gnupg
    pkgs.nix-prefetch-github
    pkgs.pass
    pkgs.pdfrg
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
    ./programs/i3.nix
    ./programs/i3status/default.nix
    ./programs/rofi.nix
    ./programs/neovim/default.nix
    ./programs/vale/default.nix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    DEFAULT_TODO_TXT = "~/docs/todo.txt";
  };
}
