self: super:

{
  gnupg = super.gnupg.overrideAttrs(oldAttrs: {
    configureFlags = "--with-pinentry-pgm=${self.pinentry}/bin/pinentry-curses";
  });
}
