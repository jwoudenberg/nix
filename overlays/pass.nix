self: super:

{
  pass = super.pass.overrideAttrs(oldAttrs: {
    doInstallCheck = false;
  });
}
