{ pkgs, ... }: {

  home.file.qutebrowser-config = {
    target = if builtins.currentSystem == "x86_64-darwin" then
      ".qutebrowser/config.py"
    else
      ".config/qutebrowser/config.py";
    source = ./config.py;
  };
}
