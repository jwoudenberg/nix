# Create desktop entry for creating screenshots.
# Can be written using `xdg.desktopEntries` home-manager property after
# 21.11.

{ pkgs, ... }:

let
  takeScreenshot = pkgs.writeShellScriptBin "take-screenshot" ''
    mkdir -p ~/screenshots
    grim -g "$(slurp)" ~/screenshots/screenshot_$(date --iso=seconds).png
  '';

in {
  config.home.packages = [
    (pkgs.makeDesktopItem {
      name = "Take Screenshot";
      desktopName = "Take Screenshot";
      exec = "${takeScreenshot}/bin/take-screenshot";
    })
  ];
}
