let
  sources = import ../nix/sources.nix;
  pkgs = import sources.nixpkgs { };
  resilioListeningPort = 18776;
in {
  "ai-banana" = {
    # Morph
    deployment.targetHost = "88.198.108.91";
    deployment.targetUser = "root";

    # Nix
    nixpkgs.localSystem.system = "x86_64-linux";
    nixpkgs.config.allowUnfree = true;
    system.stateVersion = "20.03";
    networking.hostName = "ai-banana";

    # Hardware
    imports = [ <nixpkgs/nixos/modules/profiles/qemu-guest.nix> ];
    boot.loader.grub.device = "/dev/sda";
    fileSystems."/" = {
      device = "/dev/sda1";
      fsType = "ext4";
    };
    fileSystems."/srv/volume1" = {
      device = "/dev/disk/by-id/scsi-0HC_Volume_6344799";
      fsType = "ext4";
      options = [ "discard" "defaults" ];
    };

    # Ssh
    services.openssh.enable = true;
    users.users.root.openssh.authorizedKeys.keys = let
      sshKeysSrc = builtins.fetchurl {
        url = "https://github.com/jwoudenberg.keys";
        sha256 = "1hz1m98r8lln50bba9d4f7gcadj4rk5mj5v6zlzxa3lxwiplc6fc";
      };
      in builtins.filter (line: line != "")
      (pkgs.lib.splitString "\n" (builtins.readFile sshKeysSrc));

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
