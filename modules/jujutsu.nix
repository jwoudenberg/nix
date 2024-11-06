{ pkgs, config, ... }:
{
  environment.systemPackages = [ pkgs.jujutsu ];

  homedir.files = {
    ".config/jj/config.toml" = pkgs.writeText "config.toml" ''
      [user]
      name = "Jasper Woudenberg"
      email = "mail@jasperwoudenberg.com"

      [ui]
      pager = "less -FRX" # the jujutsu default, set explicitly to overrule $PAGER.
      default-command = "log"

      [revsets]
      log = 'present(@) | ancestors((immutable_heads().. & mine())::, 2) | trunk()'

      [revset-aliases]
      "immutable_heads()" = "trunk()"
    '';
  };
}
