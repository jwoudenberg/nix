{ pkgs, config, ... }: {
  home.file."${config.xdg.configHome}/nvim/spell/nl.utf-8.spl".source =
    builtins.fetchurl {
      url = "http://ftp.vim.org/vim/runtime/spell/nl.utf-8.spl";
      sha256 = "sha256:1v4knd9i4zf3lhacnkmhxrq0lgk9aj4iisbni9mxi1syhs4lfgni";
    };

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

    extraConfig = let
      configText = builtins.replaceStrings [ "similar-sort" ]
        [ "${pkgs.similar-sort}/bin/similar-sort" ]
        (builtins.readFile ./init.lua);
    in ''
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
      polyglot
      quickfix-reflector-vim
      todo-txt-vim
      nvim-treesitter.withAllGrammars
      vim-abolish
      pkgs.vim-apl
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
      vim-visualstar
    ];
  };
}
