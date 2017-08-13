{ pkgs }:

pkgs.neovim.override {
  vimAlias = true;
  withPython = true;
  withPython3 = true;
  withRuby = true;
  configure = {
    customRC = ''
      source ~/.config/nvim/init.vim
      '';
  };
}
