{ pkgs, config, ... }:
{
  homedir.files = {
    ".config/nvim/init.lua" = ./neovim/init.lua;
    ".config/nvim/spell/nl.utf-8.spl" = pkgs.vim-spell-nl;
    ".local/share/nvim/site/pack/plugins/start/ale" = pkgs.vimPlugins.ale;
    ".local/share/nvim/site/pack/plugins/start/comment-nvim" = pkgs.vimPlugins.comment-nvim;
    ".local/share/nvim/site/pack/plugins/start/fzfWrapper" = pkgs.vimPlugins.fzfWrapper;
    ".local/share/nvim/site/pack/plugins/start/gitsigns-nvim" = pkgs.vimPlugins.gitsigns-nvim;
    ".local/share/nvim/site/pack/plugins/start/melange-nvim" = pkgs.vimPlugins.melange-nvim;
    ".local/share/nvim/site/pack/plugins/start/nvim-treesitter" =
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
    ".local/share/nvim/site/pack/plugins/start/nvim-treesitter-roc" = pkgs.nvim-treesitter-roc;
    ".local/share/nvim/site/pack/plugins/start/quickfix-reflector-vim" =
      pkgs.vimPlugins.quickfix-reflector-vim;
    ".local/share/nvim/site/pack/plugins/start/vim-abolish" = pkgs.vimPlugins.vim-abolish;
    ".local/share/nvim/site/pack/plugins/start/vim-dirvish" = pkgs.vimPlugins.vim-dirvish;
    ".local/share/nvim/site/pack/plugins/start/vim-eunuch" = pkgs.vimPlugins.vim-eunuch;
    ".local/share/nvim/site/pack/plugins/start/vim-fugitive" = pkgs.vimPlugins.vim-fugitive;
    ".local/share/nvim/site/pack/plugins/start/vim-noctu" = pkgs.vimPlugins.vim-noctu;
    ".local/share/nvim/site/pack/plugins/start/vim-repeat" = pkgs.vimPlugins.vim-repeat;
    ".local/share/nvim/site/pack/plugins/start/vim-rhubarb" = pkgs.vimPlugins.vim-rhubarb;
    ".local/share/nvim/site/pack/plugins/start/vim-surround" = pkgs.vimPlugins.vim-surround;
    ".local/share/nvim/site/pack/plugins/start/vim-unimpaired" = pkgs.vimPlugins.vim-unimpaired;
  };

  homedir.sessionVariables = {
    EDITOR = "nvim";
    MANPAGER = "nvim -c 'colors noctu | set laststatus=0 nonumber' +Man!";
  };

  programs.neovim = {
    enable = true;
    withPython3 = false;
    withRuby = false;
    withNodeJs = false;
    vimAlias = true;
  };

}
