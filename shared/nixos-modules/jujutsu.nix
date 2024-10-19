{ pkgs, config, ... }:
{
  environment.systemPackages = [ pkgs.jujutsu ];
}
