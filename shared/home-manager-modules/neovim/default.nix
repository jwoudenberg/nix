{ pkgs, ... }:
let
  sources = import ../../nix/sources.nix;
  nivSourceAsPlugin = p:
    pkgs.vimUtils.buildVimPlugin {
      name = p.repo;
      src = p;
    };
in {
  programs.neovim = {
    enable = true;

    withPython3 = false;
    withRuby = false;
    withNodeJs = false;

    vimAlias = true;

    extraConfig = builtins.readFile ./vimrc;

    plugins = with pkgs.vimPlugins; [
      pkgs.elm-pair-neovim-plugin
      ale
      fzf-vim
      gitgutter
      goyo
      gv-vim
      lightline-vim
      limelight-vim
      luasnip # required by nvim-cmp
      neoformat
      nord-vim
      nvim-cmp
      cmp-tabnine
      orgmode-nvim
      polyglot
      quickfix-reflector-vim
      todo-txt-vim
      vim-abolish
      vim-commentary
      vim-dirvish
      vim-eunuch
      vim-fugitive
      vim-highlightedyank
      vim-illuminate
      vim-repeat
      vim-rhubarb
      vim-signature
      vim-speeddating
      vim-surround
      vim-unimpaired
      vim-vinegar
      vim-visualstar
    ];
  };
}
