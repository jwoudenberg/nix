{ pkgs, config, ... }:
let
  sources = import ../../nix/sources.nix;
  nivSourceAsPlugin = p:
    pkgs.vimUtils.buildVimPlugin {
      name = p.repo;
      src = p;
    };
  nvim-spell-nl-utf8-dictionary = builtins.fetchurl {
    url = "http://ftp.vim.org/vim/runtime/spell/nl.utf-8.spl";
    sha256 = "sha256:1v4knd9i4zf3lhacnkmhxrq0lgk9aj4iisbni9mxi1syhs4lfgni";
  };
in {
  home.file."${config.xdg.configHome}/nvim/spell/nl.utf-8.spl".source =
    nvim-spell-nl-utf8-dictionary;

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
      neoformat
      neogit
      nord-vim
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
