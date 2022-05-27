{ pkgs, ... }:

{
  home.packages = [ pkgs.vale ];
  home.file.vale_ini = {
    target = ".vale.ini";
    text = ''
      StylesPath = ${pkgs.valeStyles}

      [*]
      BasedOnStyles = proselint, write-good, Joblint, alex
    '';
  };
}
