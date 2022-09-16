{ pkgs, ... }: {
  home.packages = [
    pkgs.comma
    pkgs.croc
    pkgs.nix-prefetch-github
    pkgs.pdfgrep
    pkgs.haskellPackages.niv
    pkgs.jq
    pkgs.tabnine
    pkgs.mosh
    pkgs.nixfmt
    pkgs.random-colors
    pkgs.shellcheck
    pkgs.shy
    pkgs.similar-sort
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
    ../shared/home-manager-modules/procfile/default.nix
    ../shared/home-manager-modules/readline.nix
    ../shared/home-manager-modules/ripgrep.nix
    ../shared/home-manager-modules/ssh.nix
    ../shared/home-manager-modules/vale.nix
  ];

  programs.kitty.settings.font_size = 18;

  home.sessionVariables = {
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
  };

  xdg.configFile."nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';
}
