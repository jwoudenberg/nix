{ pkgs }:
let
  pass = pkgs.pass.overrideAttrs(oldAttrs: {
    doInstallCheck = false;
  });
in
pass.override {
  gnupg = (import ./gnupg.nix) { inherit pkgs; };
}
