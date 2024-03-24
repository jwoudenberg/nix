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

        # nvim-treesitter contains configurations for different languages. It
        # does not bundle the parsers directly, rather it specifies the
        # (github) urls where tree-sitter parsers can be found. nvim-treesitter
        # does bundle queries that make use of those parsers.
        #
        # To add a custom language to nvim-treesitter you need:
        # - A parser for the language, added below
        # - Queries for the language, also added below
        # - A nvim-treesitter parser configuration entry, added in init.lua

        roc-grammar = pkgs.tree-sitter.buildGrammar {
          language = "roc";
          version = "0.0.0";
          src = pkgs.tree-sitter-roc;
          meta.homepage = "https://github.com/faldor20/tree-sitter-roc/tree/master";
        };

        # A bare-minimum neovim plugin containing the neovim queries from the
        # tree-sitter-roc project. The convention seems to be to put queries in
        # a queries/<lang> subdirectory of the plugin, and the parser in
        # parser/<lang>.so. Then nix and neovim will make sure they're loaded.
        roc-plugin = pkgs.runCommand "tree-sitter-roc" { } ''
          mkdir -p $out/queries/roc
          cp ${pkgs.tree-sitter-roc}/neovim/queries/roc/*.scm $out/queries/roc

          mkdir -p $out/parser
          cp ${roc-grammar}/parser $out/parser/roc.so
        '';
      in
      [
        roc-plugin
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
