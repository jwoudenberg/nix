{ pkgs, ... }:
let
  fishFunctions = builtins.attrNames (builtins.readDir ./functions);
  fishFunctionFiles = builtins.map (fn: ./functions + "/${fn}") fishFunctions;
  macosInitFiles = if pkgs.stdenv.isDarwin then [./macos.fish] else [];
  fish_init_files = [./config.fish] ++ macosInitFiles ++ fishFunctionFiles;
  shellInit = ''
    ${builtins.foldl' (xs: x: "${xs}\n${builtins.readFile x}") "" fish_init_files}
    source ${pkgs.fzf}/share/fish/vendor_functions.d/fzf_key_bindings.fish
    source ${pkgs.fzf}/share/fish/vendor_conf.d/load-fzf-key-bindings.fish
  '';
in
{
  programs.fish = {
    enable = true;
    shellInit = shellInit;
    shellAliases = {
      "xclip" = "xclip -selection keyboard";
      "vimrc" = "eval $EDITOR ~/.config/nvim/init.vim";
      "vim" = "nvim";
      "todo" = "eval $EDITOR ~/docs/todo.txt";
    };
  };
}
