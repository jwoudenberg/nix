{ pkgs, ... }:

{
  home.packages = [
    pkgs.cachix
    pkgs.calibre
    pkgs.discord
    pkgs.du-dust
    pkgs.fd
    pkgs.gnupg
    pkgs.grim
    pkgs.i3status
    pkgs.imv
    pkgs.jq
    pkgs.keybase
    pkgs.croc
    pkgs.haskellPackages.niv
    pkgs.minecraft
    pkgs.nixfmt
    pkgs.nix-prefetch-github
    pkgs.nodePackages.prettier
    pkgs.pass
    pkgs.pavucontrol
    # Disabled because of security vulnerabilities in `xpdf`
    # pkgs.pdfrg
    pkgs.qutebrowser
    pkgs.random-colors
    pkgs.ripgrep
    pkgs.sd
    pkgs.shellcheck
    pkgs.similar-sort
    pkgs.slurp
    pkgs.tmate
    pkgs.todo
    pkgs.vale
    pkgs.wl-clipboard
    pkgs.wofi
    pkgs.xdg_utils
    pkgs.ytop
    pkgs.zoom-us
  ];

  imports = [
    ../programs/alacritty.nix
    ../programs/direnv.nix
    ../programs/firefox.nix
    ../programs/fish/default.nix
    ../programs/fzf.nix
    ../programs/git.nix
    ../programs/i3status/default.nix
    ../programs/neovim/default.nix
    ../programs/qutebrowser/default.nix
    ../programs/readline.nix
    ../programs/ripgrep.nix
    ../programs/sway.nix
    ../programs/vale/default.nix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    DEFAULT_TODO_TXT = "~/docs/todo.txt";
    MANPAGER = "nvim -c 'set ft=man' -";
  };

  home.stateVersion = "20.03";
}
