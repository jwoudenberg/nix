final: prev:
let
  pinentry = prev.pinentry.override ({ enabledFlavors = [ "curses" ]; });
  gnupg = prev.gnupg.overrideAttrs (oldAttrs: {
    configureFlags = "--with-pinentry-pgm=${pinentry}/bin/pinentry";
  });
in {
  pass = (prev.pass.override {
    waylandSupport = !prev.stdenv.isDarwin;
    gnupg = gnupg;
  }).overrideAttrs (oldAttrs: {
    # The install check fails on MacOS.
    doInstallCheck = false;
  });
}
