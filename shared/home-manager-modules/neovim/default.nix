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
        configText = builtins.replaceStrings [ "similar-sort" ]
          [ "${pkgs.similar-sort}/bin/similar-sort" ]
          (builtins.readFile ./init.lua);
      in
      ''
        lua << EOF
        ${configText}
        EOF
      '';

    plugins = with pkgs.vimPlugins; [
      ale
      fzfWrapper
      gitsigns-nvim
      lightline-vim
      nord-vim
      quickfix-reflector-vim
      todo-txt-vim
      nvim-treesitter.withAllGrammars
      vim-abolish
      vim-commentary
      vim-dirvish
      vim-eunuch
      vim-fugitive
      vim-illuminate
      vim-noctu # colorscheme when using Vim as a pager
      vim-repeat
      vim-rhubarb
      vim-signature
      vim-speeddating
      vim-surround
      vim-unimpaired
    ];
  };
}
