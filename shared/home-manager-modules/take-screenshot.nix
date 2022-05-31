{ pkgs, config, ... }:

let
  takeScreenshot = pkgs.writeShellScriptBin "take-screenshot" ''
    mkdir -p ~/screenshots
    ${pkgs.grim}/bin/grim \
      -g "$(${pkgs.slurp}/bin/slurp)" \
      "${config.home.homeDirectory}/screenshots/screenshot_$(date --iso=seconds).png"
  '';

in {
  xdg.desktopEntries.take-screenshot = {
    name = "Take Screenshot";
    exec = "${takeScreenshot}/bin/take-screenshot";
  };
}
