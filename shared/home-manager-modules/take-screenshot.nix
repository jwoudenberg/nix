{ pkgs, config, ... }:

let
  takeScreenshot = pkgs.writeShellScriptBin "take-screenshot" ''
    mkdir -p ~/screenshots
    file="${config.home.homeDirectory}/screenshots/screenshot_$(date --iso=seconds).png"
    ${pkgs.grim}/bin/grim \
      -g "$(${pkgs.slurp}/bin/slurp)" \
      "$file"

    ${pkgs.wl-clipboard}/bin/wl-copy --foreground < "$file"
  '';

in {
  xdg.desktopEntries.take-screenshot = {
    name = "Take Screenshot";
    exec = "${takeScreenshot}/bin/take-screenshot";
  };
}
