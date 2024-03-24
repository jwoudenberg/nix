{ pkgs, config, ... }: {
  home.file."${config.xdg.configHome}/nvim/spell/nl.utf-8.spl".source =
    pkgs.vim-spell-nl;

  home.sessionVariables = {
    EDITOR = "nvim";
    MANPAGER = "nvim -c 'colors noctu | set laststatus=0 nonumber' +Man!";
  };

  programs.neovim = {
    enable = true;

    withPython3 = false;
    withRuby = false;
    withNodeJs = false;

    vimAlias = true;

    extraConfig =
      let
        configText = pkgs.lib.replaceStrings [ "similar-sort" ]
          [ "${pkgs.similar-sort}/bin/similar-sort" ]
          (pkgs.lib.readFile ./init.lua);
      in
      ''
        lua << EOF
        ${configText}
        EOF
      '';

    plugins =
      let
        plugins = pkgs.vimPlugins;
      in
      [
        pkgs.nvim-treesitter-roc
        plugins.ale
        plugins.comment-nvim
        plugins.fzfWrapper
        plugins.gitsigns-nvim
        plugins.quickfix-reflector-vim
        plugins.melange-nvim
        plugins.nvim-treesitter.withAllGrammars
        plugins.vim-abolish
        plugins.vim-dirvish
        plugins.vim-eunuch
        plugins.vim-fugitive
        plugins.vim-illuminate
        plugins.vim-noctu # colorscheme when using Vim as a pager
        plugins.vim-repeat
        plugins.vim-rhubarb
        plugins.vim-surround
        plugins.vim-unimpaired
      ];
  };
}
