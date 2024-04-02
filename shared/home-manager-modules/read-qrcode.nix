{ pkgs, config, ... }:

let
  readQrcode = pkgs.writeShellScriptBin "read-qrcode" ''
    pushd "$(mktemp -d)"
    ${pkgs.grim}/bin/grim \
      -g "$(${pkgs.slurp}/bin/slurp)" \
      screen.png
    ${pkgs.zbar}/bin/zbarimg --quiet screen.png \
      | sed 's/QR-Code://' \
      | ${pkgs.wl-clipboard}/bin/wl-copy --foreground
  '';

in {
  xdg.desktopEntries.read-qrcode = {
    name = "Read QR-code";
    exec = "${readQrcode}/bin/read-qrcode";
  };
}
