{ pkgs, ... }:

let
  iso-to-usb =
    pkgs.writeScriptBin "iso-to-usb" (builtins.readFile ./iso-to-usb.sh);
  format-usb = pkgs.writeShellApplication {
    name = "format-usb";
    text = builtins.readFile ./format-usb.sh;
    runtimeInputs = [ pkgs.parted pkgs.exfat ];
  };
in { home.packages = [ iso-to-usb format-usb ]; }
