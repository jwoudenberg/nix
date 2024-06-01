{ pkgs, ... }:
{
  services.pcscd.enable = true;
  services.yubikey-agent.enable = true;

  # Use yubikey-agent for ssh access. Need to use a graphical pinentry option
  # here instead of curses, because pinentry is called by the yubikey-agent
  # daemon and so doesn't have a connection with the active terminal.
  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-qt;
}
