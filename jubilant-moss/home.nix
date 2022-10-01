inputs:
{ pkgs, ... }:

{
  home.packages = [
    pkgs.comma
    pkgs.croc
    pkgs.gotop
    pkgs.home-manager
    pkgs.imv
    pkgs.jq
    pkgs.remind
    pkgs.zathura
    pkgs.nixfmt
    pkgs.pdfgrep
    pkgs.random-colors
    pkgs.shellcheck
    pkgs.signal-desktop
    pkgs.similar-sort
    pkgs.shy
    pkgs.perlPackages.vidir
    pkgs.visidata
    pkgs.wally-cli
    pkgs.wl-clipboard
    pkgs.xdg_utils
  ];

  imports = [
    ../shared/home-manager-modules/direnv.nix
    ../shared/home-manager-modules/fish/default.nix
    ../shared/home-manager-modules/fzf.nix
    ../shared/home-manager-modules/git.nix
    ../shared/home-manager-modules/keepassxc-pass-frontend.nix
    ../shared/home-manager-modules/kitty.nix
    ../shared/home-manager-modules/neovim/default.nix
    ../shared/home-manager-modules/nix-index.nix
    ../shared/home-manager-modules/procfile/default.nix
    ../shared/home-manager-modules/readline.nix
    ../shared/home-manager-modules/ripgrep.nix
    ../shared/home-manager-modules/ssh.nix
    ../shared/home-manager-modules/vale.nix
    ../shared/home-manager-modules/yubikey-agent.nix
  ];

  programs.kitty.settings.font_size = 15;
  programs.ssh.userKnownHostsFile = "/persist/ssh/known_hosts";

  home.sessionVariables = {
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
  };

  xdg.configFile."nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';

  nixpkgs.overlays = [ inputs.self.overlays.linuxCustomPkgs ];
}
