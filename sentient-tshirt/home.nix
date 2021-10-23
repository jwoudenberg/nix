{ pkgs, ... }: {
  home.packages = [
    pkgs.cachix
    pkgs.du-dust
    pkgs.fd
    pkgs.gnupg
    pkgs.gotop
    pkgs.nix-prefetch-github
    pkgs.pass
    pkgs.pdfgrep
    pkgs.haskellPackages.niv
    pkgs.jq
    pkgs.tabnine
    pkgs.mosh
    pkgs.nixfmt
    pkgs.nodePackages.prettier
    pkgs.random-colors
    pkgs.ripgrep
    pkgs.sd
    pkgs.shellcheck
    pkgs.similar-sort
    pkgs.vale
  ];

  imports = [
    ../shared/home-manager-modules/direnv.nix
    ../shared/home-manager-modules/fish/default.nix
    ../shared/home-manager-modules/fzf.nix
    ../shared/home-manager-modules/git.nix
    ../shared/home-manager-modules/kitty.nix
    ../shared/home-manager-modules/neovim/default.nix
    ../shared/home-manager-modules/ripgrep.nix
    ../shared/home-manager-modules/readline.nix
    ../shared/home-manager-modules/vale/default.nix
  ];

  programs.kitty.settings.font_size = 18;

  home.sessionVariables = {
    EDITOR = "nvim";
    DEFAULT_TODO_TXT = "~/docs/todo.txt";
    SSL_CERT_FILE = "/usr/local/etc/openssl/cert.pem";
    MANPAGER = "nvim -c 'set ft=man' -";
  };

  home.stateVersion = "20.03";

  xdg.configFile."nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';
}
