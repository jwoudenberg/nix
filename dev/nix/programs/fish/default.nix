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

    source ${pkgs.fzf}/share/fish/vendor_functions.d/fzf_key_bindings.fish
    source ${pkgs.fzf}/share/fish/vendor_conf.d/load-fzf-key-bindings.fish
    random-colors --hook=fish | source

    ${builtins.foldl' (xs: x: ''
      ${xs}
      ${builtins.readFile x}'') "" fishFunctionFiles}
  '';
in {
  programs.fish = {
    enable = true;
    shellInit = shellInit;
    shellAliases = {
      "ls" = "${pkgs.exa}/bin/exa";
      "cat" = "${pkgs.bat}/bin/bat";
      "find" = "${pkgs.fd}/bin/fd";
      "grep" = "${pkgs.ripgrep}/bin/rg";
    };
  };
}
