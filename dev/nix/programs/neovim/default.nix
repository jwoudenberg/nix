{ pkgs, ... }:
let
  sources = import ../../nix/sources.nix;
  customPlugin = p:
    pkgs.vimUtils.buildVimPlugin {
      name = p.repo;
      src = p;
    };
in {
  programs.neovim = {
    enable = true;

    withPython = false;
    withPython3 = true;
    withRuby = false;
    withNodeJs = false;

    vimAlias = true;

    extraConfig = builtins.readFile ./vimrc;

    plugins = with pkgs.vimPlugins; [
      (customPlugin sources.vim-dogrun)
      (customPlugin sources.vim-tabnine)
      ale
      fzf-vim
      fzfWrapper
      gitgutter
      goyo
      gv-vim
      lightline-vim
      limelight-vim
      neoformat
      polyglot
      quickfix-reflector-vim
      todo-txt-vim
      vim-abolish
      vim-commentary
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
