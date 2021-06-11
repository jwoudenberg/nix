{ pkgs, ... }:
let
  pinentry = pkgs.pinentry.override ({ enabledFlavors = [ "curses" ]; });
  gnupg = pkgs.gnupg.overrideAttrs (oldAttrs: {
    configureFlags = "--with-pinentry-pgm=${pinentry}/bin/pinentry";
  });
  pass = (pkgs.pass.override {
    waylandSupport = true;
    gnupg = gnupg;
  });
in { config.home.packages = [ pass ]; }
