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

  takeScreenshotDesktop = pkgs.writeTextDir "share/applications/take-screenshot.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=Take Screenshot
    Exec=${takeScreenshot}/bin/take-screenshot
  '';

  makeScreenrecDesktop = pkgs.writeTextDir "share/applications/record-screen.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=Make Screen Recording
    Exec=${makeScreenrec}/bin/record-screen
  '';
in
{
  environment.systemPackages = [
    takeScreenshotDesktop
    makeScreenrecDesktop
  ];
}
