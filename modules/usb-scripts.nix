{ pkgs, ... }:

let
  iso-to-usb = pkgs.writeScriptBin "iso-to-usb" (pkgs.lib.readFile ./usb-scripts/iso-to-usb.sh);
  format-usb = pkgs.writeShellApplication {
    name = "format-usb";
    text = pkgs.lib.readFile ./usb-scripts/format-usb.sh;
    runtimeInputs = [
      pkgs.parted
      pkgs.exfat
    ];
  };
in
{
  environment.systemPackages = [
    iso-to-usb
    format-usb
  ];
}
