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
      fzfWrapper
      gitsigns-nvim
      lightline-vim
      luasnip # required by nvim-cmp
      neoformat
      neogit
      nord-vim
      nvim-cmp
      cmp-tabnine
      plenary-nvim # required by neogit
      polyglot
      quickfix-reflector-vim
      todo-txt-vim
      vim-abolish
      vim-commentary
      vim-dirvish
      vim-eunuch
      vim-fugitive
      vim-illuminate
      vim-repeat
      vim-rhubarb
      vim-signature
      vim-speeddating
      vim-subversive
      vim-surround
      vim-unimpaired
      vim-visualstar
    ];
  };
}
