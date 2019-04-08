{ pkgs, ... }:

{
  home.file.vale_ini= {
    target = ".vale.ini";
    source = ./_vale.ini;
  };
}
