{ pkgs, ... }:
let
  customPlugins = pkgs.callPackage ./custom-plugins.nix {};
in
{
  programs.neovim = {
    enable = true;

    withPython = true;
    withPython3 = true;
    withRuby = true;

    configure = {
      customRC = builtins.readFile ./vimrc;

      vam.knownPlugins = pkgs.vimPlugins // customPlugins;
      vam.pluginDictionaries = [
        { name = "ale"; }
        { name = "cursor-line-current-window"; }
        { name = "dracula"; }
        { name = "fzf-vim"; }
        { name = "gitgutter"; }
        { name = "lightline-vim"; }
        { name = "neoformat"; }
        { name = "polyglot"; }
        { name = "quickfix-reflector"; }
        { name = "todo"; }
        { name = "unimpaired"; }
        { name = "vim-abolish"; }
        { name = "vim-commentary"; }
        { name = "vim-eunuch"; }
        { name = "vim-fugitive"; }
        { name = "vim-highlightedyank"; }
        { name = "vim-localvimrc"; }
        { name = "vim-rhubarb"; }
        { name = "vim-speeddating"; }
        { name = "vim-surround"; }
        { name = "vim-test"; }
        { name = "vim-vinegar"; }
        { name = "visual-star-search"; }
      ];
    };
  };
}
