{ pkgs, config, ... }:

let
  makeScreenrec = pkgs.writeShellScriptBin "make-screenrec" ''
    mkdir -p ~/screenshots
    ${pkgs.wf-recorder}/bin/wf-recorder \
      --codec libx264rgb \
      --file "${config.home.homeDirectory}/screenshots/screenrec_$(date --iso=seconds).mkv" \
      --geometry "$(${pkgs.slurp}/bin/slurp)"
  '';
in
{ home.packages = [ makeScreenrec ]; }
