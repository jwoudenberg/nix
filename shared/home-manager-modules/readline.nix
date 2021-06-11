{ pkgs, ... }: {
  programs.readline = {
    enable = true;
    extraConfig = ''
      set editing-mode vi
      set show-mode-in-prompt on
    '';
  };
}
