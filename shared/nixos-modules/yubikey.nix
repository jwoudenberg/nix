{ pkgs, ... }: {
  services.pcscd.enable = true;

  services.yubikey-agent.enable = true;
  systemd.user.services.yubikey-agent.wantedBy = [ "graphical-session.target" ];

  # Use yubikey-agent for ssh access. Need to use a graphical pinentry option
  # here instead of curses, because pinentry is called by the yubikey-agent
  # daemon and so doesn't have a connection with the active terminal.
  programs.gnupg.agent.pinentryFlavor = "qt";
  environment.systemPackages = [ pkgs.pinentry ];
}
