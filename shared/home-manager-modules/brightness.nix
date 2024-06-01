{ pkgs, ... }:

let
  brighter = pkgs.writeShellScriptBin "brighter" "${pkgs.ddcutil}/bin/ddcutil setvcp 10 + 10";
  duller = pkgs.writeShellScriptBin "duller" "${pkgs.ddcutil}/bin/ddcutil setvcp 10 - 10";
in
{
  home.packages = [
    brighter
    duller
  ];
}
