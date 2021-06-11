{ pkgs, ... }:

{
  home.packages = [
    pkgs.cachix
    pkgs.calibre
    pkgs.chromium
    pkgs.discord
    pkgs.du-dust
    pkgs.fd
    pkgs.gnupg
    pkgs.gotop
    pkgs.grim
    pkgs.i3status
    pkgs.imv
    pkgs.jq
    pkgs.keybase
    pkgs.magic-wormhole
    pkgs.mosh
    pkgs.zathura
    pkgs.haskellPackages.niv
    pkgs.minecraft
    pkgs.nixfmt
    pkgs.nix-prefetch-github
    pkgs.nodePackages.prettier
    pkgs.pdfgrep
    pkgs.pulsemixer
    pkgs.plex-media-player
    pkgs.podman
    pkgs.random-colors
    pkgs.ripgrep
    pkgs.sd
    pkgs.shellcheck
    pkgs.similar-sort
    pkgs.slurp
    pkgs.tabnine
    pkgs.tmate
    pkgs.vale
    pkgs.wally-cli
    pkgs.wl-clipboard
    pkgs.xdg_utils
    pkgs.zoom-us
  ];

  imports = [
    ../programs/direnv.nix
    ../programs/firefox.nix
    ../programs/fish/default.nix
    ../programs/fzf.nix
    ../programs/git.nix
    ../programs/i3status/default.nix
    ../programs/kitty.nix
    ../programs/neovim/default.nix
    ../programs/pass.nix
    ../programs/readline.nix
    ../programs/ripgrep.nix
    ../programs/ssh.nix
    ../programs/sway.nix
    ../programs/take-screenshot.nix
    ../programs/vale/default.nix
    ../programs/wlsunset.nix
  ];

  programs.kitty.settings.font_size = 14;

  home.sessionVariables = {
    EDITOR = "nvim";
    DEFAULT_TODO_TXT = "~/docs/todo.txt";
    MANPAGER = "nvim -c 'set ft=man' -";
    AWS_VAULT_BACKEND = "file";
    # Fix issue with opening links in Firefox using :GBrowse.
    MOZ_DBUS_REMOTE = "1";
  };

  home.stateVersion = "21.05";

  xdg.configFile."nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
    };
  };
}
