{ pkgs, ... }: {
  home.file.".bash_profile".text = ''
    sway
  '';
}
