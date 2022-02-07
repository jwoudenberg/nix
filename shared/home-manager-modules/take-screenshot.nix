# Create desktop entry for creating screenshots.
# Can be written using `xdg.desktopEntries` home-manager property after
# 21.11.

{ pkgs, config, ... }:

let
  takeScreenshot = pkgs.writeShellScriptBin "take-screenshot" ''
    mkdir -p ~/screenshots
    ${pkgs.grim}/bin/grim \
      -g "$(${pkgs.slurp}/bin/slurp)" \
      "${config.home.homeDirectory}/screenshots/screenshot_$(date --iso=seconds).png"
  '';

in {
  home.packages = [
    (pkgs.makeDesktopItem {
      name = "Take Screenshot";
      desktopName = "Take Screenshot";
      exec = "${takeScreenshot}/bin/take-screenshot";
    })
  ];
}
