{ pkgs, ... }:
{

  homedir.files = {
    ".inputrc" = pkgs.writeText "inputrc" ''
      $include /etc/inputrc
      set editing-mode vi
      set show-mode-in-prompt on
    '';
  };
}
