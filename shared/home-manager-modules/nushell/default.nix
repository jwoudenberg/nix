{ pkgs, config, lib, ... }:

{
  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    extraConfig = ''
      alias diary = ${./diary.nu}
    '';
    envFile.text = let
      # Adapted from similar logic for other shells in home-manager:
      # https://github.com/nix-community/home-manager/blob/master/modules/lib/shell.nix

      # Produces a nushell export statement
      export = n: v: ''let-env ${n} = $"${toString v}"'';

      # Given an attribute set containing shell variable names and their
      # assignment, this function produces a string containing an export
      # statement for each set entry.
      exportAll = vars:
        lib.concatStringsSep "\n" (lib.mapAttrsToList export vars);
    in exportAll config.home.sessionVariables;
  };
}
