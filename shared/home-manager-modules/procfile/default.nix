{ pkgs, ... }:

let procfile = pkgs.writeScriptBin "procfile" (pkgs.lib.readFile ./procfile.sh);
in { home.packages = [ procfile ]; }
