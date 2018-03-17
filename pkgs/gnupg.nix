{ pkgs }:

let
  pinentry = pkgs.pinentry.override {
    ncurses = pkgs.ncurses;
  };
  gnupg = pkgs.gnupg.overrideAttrs(oldAttrs: rec {
    pinentryBinaryPath = "bin/pinentry-curses";
    configureFlags = "--with-pinentry-pgm=${pinentry}/${pinentryBinaryPath}";
  });
in
gnupg.override {
  libusb = pkgs.libusb;
  pinentry = pinentry;
}
