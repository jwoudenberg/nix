{ pkgs }:

let
  pinentry = pkgs.pinentry.override {
    gcr = null;
    gtk2 = null;
    qt = null;
  };
in
pkgs.gnupg.overrideAttrs(oldAttrs: {
  configureFlags = "--with-pinentry-pgm=${pinentry}/bin/pinentry-curses";
})
