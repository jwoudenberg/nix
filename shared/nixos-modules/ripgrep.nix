{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.ripgrep ];
  # Ensure ripgrep doesn't find files in `.git`, even when the `--hidden` flag
  # is passed.
  homedir.files.".ignore" = pkgs.writeText ".ignore" ''
    .git
  '';
}
