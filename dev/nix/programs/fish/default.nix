{ pkgs, ... }:
let
  fishFunctions = builtins.attrNames (builtins.readDir ./functions);
  fishFunctionFiles = builtins.map (fn: ./functions + "/${fn}") fishFunctions;
  fish_init_files = [ ./config.fish ] ++ fishFunctionFiles;
  shellInit = ''
    ${builtins.foldl' (xs: x: ''
      ${xs}
      ${builtins.readFile x}'') "" fish_init_files}
    source ${pkgs.fzf}/share/fish/vendor_functions.d/fzf_key_bindings.fish
    source ${pkgs.fzf}/share/fish/vendor_conf.d/load-fzf-key-bindings.fish
    random-colors --hook=fish | source
  '';
in {
  programs.fish = {
    enable = true;
    shellInit = shellInit;
    shellAliases = {
      "ls" = "${pkgs.exa}/bin/exa";
      "cat" = "${pkgs.bat}/bin/bat";
    };
  };
}
