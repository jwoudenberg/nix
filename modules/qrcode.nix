{ pkgs, ... }:

let
  qrcode = pkgs.writeShellScriptBin "qrcode" ''
    ${pkgs.qrencode}/bin/qrencode --type UTF8i "$@"
  '';

  readQrcode = pkgs.writeShellScriptBin "read-qrcode" ''
    pushd "$(mktemp -d)"
    ${pkgs.grim}/bin/grim \
      -g "$(${pkgs.slurp}/bin/slurp)" \
      screen.png
    ${pkgs.zbar}/bin/zbarimg --quiet screen.png \
      | sed 's/QR-Code://' \
      | ${pkgs.wl-clipboard}/bin/wl-copy --foreground
  '';

in
{
  environment.systemPackages = [ qrcode ];

  homedir.files = {
    ".local/share/applications/read-qrcode.desktop" = pkgs.writeText "read-qrcode.desktop" ''
      Type=Application
      Name=Read QR-code
      Exec=${readQrcode}/bin/read-qrcode
    '';
  };
}
