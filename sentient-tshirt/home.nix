{ pkgs, ... }: {
  home.packages = [
    pkgs.comma
    pkgs.croc
    pkgs.gotop
    pkgs.nix-prefetch-github
    pkgs.pdfgrep
    pkgs.haskellPackages.niv
    pkgs.jq
    pkgs.tabnine
    pkgs.mosh
    pkgs.nixfmt
    pkgs.random-colors
    pkgs.ripgrep
    pkgs.shellcheck
    pkgs.shy
    pkgs.similar-sort
    pkgs.vale
  ];

  imports = [
    ../shared/home-manager-modules/direnv.nix
    ../shared/home-manager-modules/fish/default.nix
    ../shared/home-manager-modules/fzf.nix
    ../shared/home-manager-modules/git.nix
    ../shared/home-manager-modules/keepassxc-pass-frontend.nix
    ../shared/home-manager-modules/kitty.nix
    ../shared/home-manager-modules/nix-index.nix
    ../shared/home-manager-modules/neovim/default.nix
    ../shared/home-manager-modules/readline.nix
    ../shared/home-manager-modules/ripgrep.nix
    ../shared/home-manager-modules/ssh.nix
    ../shared/home-manager-modules/vale/default.nix
  ];

  programs.kitty.settings.font_size = 18;

  home.sessionVariables = {
    EDITOR = "nvim";
    DEFAULT_TODO_TXT = "~/docs/org/todo.org";
    MANPAGER = "nvim +Man!";
  };

  xdg.configFile."nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';
}
