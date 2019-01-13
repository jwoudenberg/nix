{ pkgs, ... }:
let
  fish_functions = builtins.attrNames (builtins.readDir ./functions);
  fish_function_files = builtins.map (fn: ./functions + "/${fn}") fish_functions;
  fish_init_files = [./config.fish] ++ fish_function_files;
  shellInit = builtins.foldl' (xs: x: "${xs}\n${builtins.readFile x}") "" fish_init_files;
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
