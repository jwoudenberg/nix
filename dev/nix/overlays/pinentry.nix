self: super:

{
  pinentry = super.pinentry.override {
    gcr = null;
    gtk2 = null;
    qt4 = null;
    qt5 = null;
  };
}
