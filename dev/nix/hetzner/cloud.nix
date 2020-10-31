let
  sources = import ../nix/sources.nix;
  pkgs = import sources.nixpkgs { };
  resilioListeningPort = 18776;
in {
  "ai-banana.jasperwoudenberg.com" = {
    # Morph
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

    # healthchecks.io
    services.cron.enable = true;
    services.cron.systemCronJobs = [
      "0 * * * *      root    systemctl is-active --quiet plex && curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/8177d382-5f65-465c-8e41-50b0a9291c9f"
    ];

    # Resilio Sync
    system.activationScripts.mkmusic = ''
      mkdir -p /srv/volume1/music
      chown rslsync:rslsync -R /srv/volume1/music
    '';

    networking.firewall.allowedTCPPorts = [ resilioListeningPort 80 443 ];
    networking.firewall.allowedUDPPorts = [ resilioListeningPort 80 443 ];

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
    # When recreating we need to run Plex setup again. To do so:
    # 1. Set `openFirewall = false;` (so no-one can claim the unconfigured server)
    # 2. ssh -L 32400:localhost:32400 root@ai-banana.jasperwoudenberg.com
    # 3. In the browser login at localhost:32400/web and follow the instructions
    # 4. Set `openFirewall = true;`
    services.plex = {
      enable = true;
      openFirewall = true;
    };

    # Caddy
    services.caddy = {
      enable = true;
      agree = true;
      email = "letsencrypt@jasperwoudenberg.com";
      config = ''
        ai-banana.jasperwoudenberg.com {
          respond "Hello, world!"
        }
      '';
    };
  };
}
