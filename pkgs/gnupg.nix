{ pkgs }:

let
  pinentry = pkgs.pinentry.override {
    ncurses = pkgs.ncurses;
  };
in
pkgs.gnupg.override {
  libusb = pkgs.libusb;
  pinentry = pinentry;
}
