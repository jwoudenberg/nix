{ pkgs, config, ... }:
{
  environment.systemPackages = [ pkgs.jujutsu ];

  homedir.files = {
    ".config/jj/config.toml" = pkgs.writeText "config.toml" ''
      [user]
      name = "Jasper Woudenberg"
      email = "mail@jasperwoudenberg.com"
    '';
  };
}
