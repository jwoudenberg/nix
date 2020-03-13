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
      vim-dogrun
      fzf-vim
      fzfWrapper
      gitgutter
      goyo
      gv
      lightline-vim
      limelight-vim
      neoformat
      polyglot
      quickfix-reflector-vim
      tabnine
      todo
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
