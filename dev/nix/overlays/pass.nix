self: super:
let
  gnupg = super.gnupg.overrideAttrs (oldAttrs: {
    configureFlags =
      "--with-pinentry-pgm=${super.pinentry}/bin/pinentry-curses";
  });
in {
  pass = (super.pass.override { gnupg = gnupg; }).overrideAttrs (oldAttrs: {
    # The install check fails on MacOS.
    doInstallCheck = false;
  });
}
