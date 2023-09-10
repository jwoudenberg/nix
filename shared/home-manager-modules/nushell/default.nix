{ pkgs, config, lib, ... }:

{
  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    extraConfig = ''
      alias diary = ${./diary.nu}

      def remind [--months (-m): int = 1] {
        let startOfToday = (date now | date format '%Y/%m/%d' | into datetime)
        (
          ${pkgs.remind}/bin/remind $"-ppp($months)" ~/hjgames/agenda/
            | from json
            | each { get entries }
            | flatten
            | each {
                |event| {
                  body: $event.body
                  date: ($event | get -i eventstart | default $event.date | into datetime)
                }
              }
            | where date >= $startOfToday
            | sort-by date
        )
      }

      # Display events for today
      remind | where date < (date now) + 1day | get --ignore-errors body | str join "\n"
    '';
    envFile.text = let
      # Adapted from similar logic for other shells in home-manager:
      # https://github.com/nix-community/home-manager/blob/master/modules/lib/shell.nix

      # Produces a nushell export statement
      export = n: v: ''$env.${n} = $"${toString v}"'';

      # Given an attribute set containing shell variable names and their
      # assignment, this function produces a string containing an export
      # statement for each set entry.
      exportAll = vars:
        lib.concatStringsSep "\n" (lib.mapAttrsToList export vars);
    in exportAll config.home.sessionVariables;
  };
}
