let
  fish_functions = builtins.attrNames (builtins.readDir ./functions);
  fish_function_files = builtins.map (fn: ./functions + "/${fn}") fish_functions;
  fish_init_files = [./config.fish] ++ fish_function_files;
  shellInit = builtins.foldl' (xs: x: "${xs}\n${builtins.readFile x}") "" fish_init_files;
in
{
  enable = true;
  shellInit = shellInit;
  shellAliases = {
    "xclip" = "xclip -selection keyboard";
    "vimrc" = "$EDITOR ~/.config/nvim/init.vim";
    "vim" = "env nvim";
    "nvim" = "env nvim";
    "todo" = "$EDITOR ~/docs/todo.txt";
    "nri" = "$EDITOR ~/docs/nri";
  };
}
