{ pkgs, ... }: {
  systemd.user.services.yubikey-agent = {
    Unit = {
      Description = "Seamless ssh-agent for YubiKeys";
      Documentation = "https://filippo.io/yubikey-agent";
    };

    Service = {
      ExecStart =
        "${pkgs.yubikey-agent}/bin/yubikey-agent -l %t/yubikey-agent/yubikey-agent.sock";
      ExecReload = "/bin/kill -HUP $MAINPID";
      IPAddressDeny = "any";
      RestrictAddressFamilies = "AF_UNIX";
      RestrictNamespaces = "yes";
      RestrictRealtime = "yes";
      RestrictSUIDSGID = "yes";
      LockPersonality = "yes";
      SystemCallFilter = [ "@system-service" "~@privileged @resources" ];
      SystemCallErrorNumber = "EPERM";
      SystemCallArchitectures = "native";
      NoNewPrivileges = "yes";
      KeyringMode = "private";
      UMask = "0177";
      RuntimeDirectory = "yubikey-agent";
    };

    Install = { WantedBy = [ "default.target" ]; };
  };

  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/yubikey-agent/yubikey-agent.sock";
  };
}
