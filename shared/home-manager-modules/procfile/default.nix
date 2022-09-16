{ pkgs, ... }:

let procfile = pkgs.writeScriptBin "procfile" (builtins.readFile ./procfile.sh);
in { home.packages = [ procfile ]; }
