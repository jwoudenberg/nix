{ pkgs, ... }:
let
  pass = (pkgs.pass.override {
    waylandSupport = true;
    gnupg = pkgs.gnupg-customized;
  });
in { config.home.packages = [ pass ]; }
