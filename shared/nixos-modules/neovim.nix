{ pkgs, config, ... }:
{
  config.homedir.files = {
    ".config/nvim/init.lua" = ../home-manager-modules/neovim/init.lua;
    ".config/nvim/spell/nl.utf-8.spl" = "${pkgs.vim-spell-nl}";
  };
}
