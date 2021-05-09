self: super:
let
  pinentry = super.pinentry.override ({ enabledFlavors = [ "curses" ]; });
  gnupg = super.gnupg.overrideAttrs (oldAttrs: {
    configureFlags = "--with-pinentry-pgm=${pinentry}/bin/pinentry";
  });
in {
  pass = (super.pass.override {
    waylandSupport = !super.stdenv.isDarwin;
    gnupg = gnupg;
  }).overrideAttrs (oldAttrs: {
    # The install check fails on MacOS.
    doInstallCheck = false;
  });
}
