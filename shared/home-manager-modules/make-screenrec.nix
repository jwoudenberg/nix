{ pkgs, config, ... }:

let
  makeScreenrec = pkgs.writeShellScriptBin "make-screenrec" ''
    mkdir -p ~/screenshots
    ${pkgs.wf-recorder}/bin/wf-recorder \
      --file "${config.home.homeDirectory}/screenshots/screenrec_$(date --iso=seconds).mp4" \
      --geometry "$(${pkgs.slurp}/bin/slurp)"
  '';
in { home.packages = [ makeScreenrec ]; }
