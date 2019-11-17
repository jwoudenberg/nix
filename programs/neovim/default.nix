{ pkgs, ... }:
let allPlugins = pkgs.vimPlugins // pkgs.callPackage ./custom-plugins.nix { };
in {
  programs.neovim = {
    enable = true;

    withPython = true;
    withPython3 = true;
    withRuby = true;
    withNodeJs = true;

    vimAlias = true;

    extraConfig = builtins.readFile ./vimrc;

    plugins = with allPlugins; [
      ale
      candid
      fzfWrapper
      fzf-vim
      gitgutter
      goyo
      gv
      lightline-vim
      neoformat
      polyglot
      quickfix-reflector-vim
      tabnine
      todo
      vim-unimpaired
      vim-abolish
      vim-commentary
      vim-eunuch
      vim-fugitive
      vim-repeat
      vim-rhubarb
      vim-signature
      vim-speeddating
      vim-surround
      vim-vinegar
      visual-star-search
    ];
  };
}
