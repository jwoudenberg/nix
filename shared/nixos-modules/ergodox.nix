# Support for flashing my Ergodox firmware.
{ pkgs, ... }: {
  hardware.keyboard.zsa.enable = true;
  environment.systemPackages = [ pkgs.wally-cli ];
}
