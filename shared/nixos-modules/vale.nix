{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.vale ];

  homedir.files.".vale_ini" = pkgs.writeText ".vale_ini" ''
    StylesPath = ${pkgs.valeStyles}

    [*]
    BasedOnStyles = proselint, write-good, Joblint, alex
  '';
}
