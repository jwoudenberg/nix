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
    pkgs.shellcheck
    pkgs.signal-desktop
    pkgs.wl-clipboard
    pkgs.xdg_utils
  ];
}
