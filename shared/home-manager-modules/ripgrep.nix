{ pkgs, ... }:
{
  home.packages = [ pkgs.ripgrep ];
  # Ensure ripgrep doesn't find files in `.git`, even when the `--hidden` flag
  # is passed.
  home.file.".ignore".text = ''
    .git
  '';
}
