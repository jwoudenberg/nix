{ pkgs, ... }:

let
  qrcode = pkgs.writeShellScriptBin "qrcode" ''
    ${pkgs.qrencode}/bin/qrencode --type UTF8i "$@"
  '';
in
{
  home.packages = [ qrcode ];
}
