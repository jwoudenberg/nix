{ pkgs, config, ... }:
{
  environment.systemPackages = [
    pkgs.agenda-txt
    pkgs.annotator
    pkgs.ics-to-agenda-txt
    pkgs.comma
    pkgs.croc
    pkgs.dedrm
    pkgs.gotop
    pkgs.cooklang
    pkgs.mosh
    pkgs.nixfmt-rfc-style
    pkgs.pdfgrep
    pkgs.pulsemixer
    pkgs.random-colors
    pkgs.samply
    pkgs.shellcheck
    pkgs.signal-desktop
    pkgs.wl-clipboard
    pkgs.xdg-utils
  ];

  imports = [
    ../modules/aerc.nix
    ../modules/age.nix
    ../modules/direnv.nix
    ../modules/fzf.nix
    ../modules/git.nix
    ../modules/imv.nix
    ../modules/jujutsu.nix
    ../modules/kitty.nix
    ../modules/neovim.nix
    ../modules/nushell.nix
    ../modules/qrcode.nix
    ../modules/qutebrowser.nix
    ../modules/readline.nix
    ../modules/ripgrep.nix
    ../modules/screengrab.nix
    ../modules/usb-scripts.nix
    ../modules/vale.nix
    ../modules/whipper.nix
    ../modules/zathura.nix
  ];
}
