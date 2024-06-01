{
  pkgs,
  config,
  lib,
  ...
}:

{
  # Seed ~/.config/nushell/history.txt with persisted history commands.
  # Using `home.file.<name.*` would create an unmodifiable symlink.
  home.activation.initNushellHistory = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    CONFIG_DIR="${config.home.homeDirectory}/.config/nushell"
    mkdir -p "$CONFIG_DIR"
    ln -sf "${config.home.homeDirectory}/docs/nushell-history.txt" "$CONFIG_DIR/history.txt"
  '';

  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    shellAliases = {
      "ssh" = "kitty +kitten ssh";
      "todo" = "^$env.EDITOR ~/docs/todo.txt";
      "agenda" = "^$env.EDITOR ~/hjgames/agenda/agenda.txt";
      "diary" = "${./diary.nu}";
      "brein" = "${./brein.nu}";
      "work" = "${./work.nu}";
      "surf" = "${./surf.nu}";
    };
    environmentVariables = {
      PROMPT_COMMAND = "{ pwd | path basename }";
      PROMPT_COMMAND_RIGHT = ''
        {
                do --ignore-errors { git branch }
                  | complete
                  | get stdout
                  | grep '^* '
                  | str substring 2..
              }'';
      PROMPT_INDICATOR = "' '";
      PROMPT_INDICATOR_VI_INSERT = "' '";
      PROMPT_INDICATOR_VI_NORMAL = "' '";
      PROMPT_MULTILINE_INDICATOR = "' '";
    };
    extraConfig = ''
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
        exportAll = vars: lib.concatStringsSep "\n" (lib.mapAttrsToList export vars);
      in
      exportAll config.home.sessionVariables;
  };
}
