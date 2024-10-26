{ pkgs, config, ... }:

let
  makeScreenrec = pkgs.writeShellScriptBin "record-screen" ''
    mkdir -p ~/screenshots
    ${pkgs.wf-recorder}/bin/wf-recorder \
      --codec libx264rgb \
      --file "/home/jasper/screenshots/screenrec_$(date --iso=seconds).mkv" \
      --geometry "$(${pkgs.slurp}/bin/slurp)"
  '';

  takeScreenshot = pkgs.writeShellScriptBin "take-screenshot" ''
    mkdir -p ~/screenshots
    file="/home/jasper/screenshots/screenshot_$(date --iso=seconds).png"
    ${pkgs.grim}/bin/grim \
      -g "$(${pkgs.slurp}/bin/slurp)" \
      "$file"

    ${pkgs.wl-clipboard}/bin/wl-copy --foreground < "$file"
  '';
in
{
  homedir.files = {
    ".local/share/applications/take-screenshot.desktop" = pkgs.writeText "read-qrcode.desktop" ''
      Type=Application
      Name=Take Screenshot
      Exec=${takeScreenshot}/bin/take-screenshot
    '';
    ".local/share/applications/record-screen.desktop" = pkgs.writeText "record-screen.desktop" ''
      Type=Application
      Name=Make Screen Recording
      Exec=${makeScreenrec}/bin/record-screen
    '';
  };
}
