{ pkgs, ... }: {
  programs.ssh = {
    enable = true;
    compression = true; # Needed by tmate
    userKnownHostsFile = let
      knownHosts = pkgs.writeTextFile {
        name = "known_hosts";
        text = ''
          github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
          ai-banana ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJtiovfQ9l6ewuahB3Zh1AnJ8+NNABHwwrqmKtVHXiQ
        '';
      };
    in "~/.ssh/known_hosts ${knownHosts}";
  };
}
