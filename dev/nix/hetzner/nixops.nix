let resilioListeningPort = 18776;
in {
  ai-banana = { config, pkgs, ... }: {
    # NixOps
    deployment.targetHost = "88.198.108.91";

    nixpkgs.config.allowUnfree = true;

    system.stateVersion = "20.03";

    # Hardware
    imports = [ <nixpkgs/nixos/modules/profiles/qemu-guest.nix> ];
    boot.loader.grub.device = "/dev/sda";
    fileSystems."/" = {
      device = "/dev/sda1";
      fsType = "ext4";
    };
    fileSystems."/srv/volume1" = {
      device = "/dev/sdb";
      fsType = "ext4";
      options = [ ];
    };

    # Ssh
    services.openssh.enable = true;
    users.users.root.openssh.authorizedKeys.keys =
      [ (builtins.readFile "${builtins.getEnv "HOME"}/.ssh/id_rsa.pub") ];

    # Resilio Sync
    system.activationScripts.mkmusic = ''
      mkdir -p /srv/volume1/music
      chown rslsync:rslsync -R /srv/volume1/music
    '';

    networking.firewall.allowedTCPPorts = [ resilioListeningPort ];
    networking.firewall.allowedUDPPorts = [ resilioListeningPort ];

    services.resilio = {
      enable = true;
      enableWebUI = false;
      listeningPort = resilioListeningPort;
      sharedFolders = [{
        secret = builtins.getEnv "RESILIO_MUSIC_READONLY";
        directory = "/srv/volume1/music";
        useRelayServer = false;
        useTracker = true;
        useDHT = true;
        searchLAN = true;
        useSyncTrash = false;
        knownHosts = [ ];
      }];
    };

    # Plex
    services.plex = {
      enable = true;
      openFirewall = true;
    };
  };
}
