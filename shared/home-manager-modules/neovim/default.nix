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

    extraConfig = ''
      lua << EOF
      ${builtins.readFile ./init.lua}
      EOF
    '';

    plugins = with pkgs.vimPlugins; [
      ale
      fzf-vim
      gitsigns-nvim
      lightline-vim
      luasnip # required by nvim-cmp
      neoformat
      nord-vim
      nvim-cmp
      cmp-tabnine
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
