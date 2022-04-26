{ pkgs, ... }:
let
  fishFunctions = builtins.attrNames (builtins.readDir ./functions);
  fishFunctionFiles = builtins.map (fn: ./functions + "/${fn}") fishFunctions;
  shellInit = ''
    # Set vi keybindings.
    fish_vi_key_bindings

    # No greeting message.
    set fish_greeting

    function fish_mode_prompt
        # overwrite the default fish_mode_prompt to show nothing.
    end

    random-colors --hook=fish | source

    ${builtins.foldl' (xs: x: ''
      ${xs}
      ${builtins.readFile x}'') "" fishFunctionFiles}

    ${pkgs.remind}/bin/remind -q -g -b1 ~/hjgames/agenda/
  '';
in {
  programs.fish = {
    enable = true;
    shellInit = shellInit;
    shellAliases = {
      "ls" = "${pkgs.exa}/bin/exa";
      "cat" = "${pkgs.bat}/bin/bat";
      "lock" = "swaylock";
      "ssh" = "kitty +kitten ssh";
      "todo" = "nvim ~/docs/todo.txt";
      "agenda" = "vim ~/hjgames/agenda/agenda.rem";
    };
  };
}
