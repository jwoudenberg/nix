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
    '';
  };
}
