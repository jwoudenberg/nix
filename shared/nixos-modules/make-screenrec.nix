{ pkgs, config, ... }:

let
  makeScreenrec = pkgs.writeShellScriptBin "make-screenrec" ''
    mkdir -p ~/screenshots
    ${pkgs.wf-recorder}/bin/wf-recorder \
      --codec libx264rgb \
      --file "/home/jasper/screenshots/screenrec_$(date --iso=seconds).mkv" \
      --geometry "$(${pkgs.slurp}/bin/slurp)"
  '';
in
{
  environment.systemPackages = [ makeScreenrec ];
}
