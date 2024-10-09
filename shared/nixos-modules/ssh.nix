{ pkgs, ... }:
{
  services.pcscd.enable = true;
  programs.ssh = {
    startAgent = true;
    enableAskPassword = true;
    askPassword = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";
  };

  homedir.files =
    let
      knownHosts = pkgs.writeTextFile {
        name = "known_hosts";
        text = ''
          github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
          ai-banana ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJtiovfQ9l6ewuahB3Zh1AnJ8+NNABHwwrqmKtVHXiQ
          airborne-cactus ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFIqsk0NjAYwiv8CG3v7YrUTd3mD1iExuyZ85eJed0l
        '';
      };
    in
    {
      ".ssh/config" = pkgs.writeText "config" ''
        Host *
          ForwardAgent no
          AddKeysToAgent no
          Compression yes
          ServerAliveInterval 0
          ServerAliveCountMax 3
          HashKnownHosts no
          UserKnownHostsFile ~/.ssh/known_hosts ${knownHosts}
          ControlMaster no
          ControlPath ~/.ssh/master-%r@%n:%p
          ControlPersist no
          VisualHostKey yes
      '';
    };
}
