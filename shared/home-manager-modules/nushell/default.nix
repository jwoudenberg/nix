{ pkgs, config, lib, ... }:

{
  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    extraConfig = ''
      alias diary = ${./diary.nu}
      alias brein = ${./brein.nu}
      alias work = ${./work.nu}

      def remind [--months (-m): int = 1] {
        cat ~/hjgames/agenda/*agenda.txt | ${pkgs.agenda-txt}/bin/agenda-txt ($"*($months)m")
      }

      # Display events for today
      ^echo (cat ~/hjgames/agenda/*agenda.txt | ${pkgs.agenda-txt}/bin/agenda-txt *1d)
    '';
    envFile.text =
      let
        # Adapted from similar logic for other shells in home-manager:
        # https://github.com/nix-community/home-manager/blob/master/modules/lib/shell.nix

        # Produces a nushell export statement
        export = n: v: ''$env.${n} = $"${toString v}"'';

        # Given an attribute set containing shell variable names and their
        # assignment, this function produces a string containing an export
        # statement for each set entry.
        exportAll = vars:
          lib.concatStringsSep "\n" (lib.mapAttrsToList export vars);
      in
      exportAll config.home.sessionVariables;
  };
}
