let
  webdavPort = 8080;
  paulusPort = 8081;
  kobodlPort = 8084;
  kobodlPort2 = 8085;
  yarrPort = 8086;
in inputs:
{ pkgs, config, modulesPath, ... }: {

  # Nix
  system.stateVersion = "21.11";
  networking.hostName = "ai-banana";
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ inputs.self.overlays.linuxCustomPkgs ];

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 1d";
  };

  # Hardware
  disabledModules = [ "services/networking/resilio.nix" ];
  imports = [
    ../shared/nixos-modules/resilio.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  boot.loader.grub.device = "/dev/sda";
  boot.cleanTmpDir = true;
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/bda03ef5-0d25-49a5-87d2-c79383443df8";
    fsType = "ext4";
  };
  fileSystems."/srv/volume1" = {
    device = "trunk/volume1";
    fsType = "zfs";
  };

  # ZFS
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.zfs.requestEncryptionCredentials = true;
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "d26b29e3";
  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
    autoSnapshot.enable = true;
  };

  # Enable IP forwarding to allow this machine to function as a tailscale exit
  # node.
  # See: https://tailscale.com/kb/1104/enable-ip-forwarding/
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

  # Packages
  environment.systemPackages = [ pkgs.tailscale pkgs.comma ];

  # Tailscale
  services.tailscale.enable = true;

  # SSH
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = let
    sshKeysSrc = builtins.fetchurl {
      url = "https://github.com/jwoudenberg.keys";
      sha256 = "sha256:1wfnzni5hw4q1jiki058l4qxxfzdbrp51d7l47bsq1wb20a7284i";
    };
  in builtins.filter (line: line != "")
  (pkgs.lib.splitString "\n" (builtins.readFile sshKeysSrc));

  # Mosh
  programs.mosh.enable = true;

  # Network
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedTCPPorts = [
      config.services.resilio.listeningPort
      22 # ssh admin
      2022 # ssh printserver
    ];
    allowedUDPPorts = [
      config.services.resilio.listeningPort
      config.services.tailscale.port
      22 # ssh admin
      2022 # ssh printserver
    ];
  };

  # healthchecks.io
  systemd.timers.healthchecks = {
    wantedBy = [ "timers.target" ];
    partOf = [ "simple-timer.service" ];
    timerConfig.OnCalendar = "hourly";
  };
  systemd.services.healthchecks = {
    serviceConfig.Type = "oneshot";
    script = ''
      set -ux    # No -e because I want to run all checks.

      # No scans waiting for processing
      ls -1qA /srv/volume1/hjgames/scans-to-process/ | grep -q . || \
        ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 -o /dev/null \
        https://hc-ping.com/8ff8704b-d08e-47eb-b879-02ddb7442fe2

      # Resilio is running
      systemctl is-active resilio && \
        ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 -o /dev/null \
        https://hc-ping.com/2d0bc35c-d03a-4ef6-8ea2-461e52b9f426

      # Enough disk space remaining
      check_free_diskspace () {
        # Taken from https://www.reddit.com/r/selfhosted/comments/fw4gjr/how_to_use_healthchecksio_to_monitor_free_disk/
        URL="https://hc-ping.com/fc58bfe1-77e7-46ea-a8a4-90096c883afd"
        PCT=$(df --output=pcent "$1" | tail -n 1 | tr -d '% ')
        if [ $PCT -gt 80 ]; then url=$url/fail; fi
        ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 -o /dev/null \
          --data-raw "Used space on $1: $PCT%" "$URL"
      }
      check_free_diskspace '/'
      check_free_diskspace '/srv/volume1'
    '';
  };

  # Resilio Sync
  system.activationScripts.mkResilioSharedFolders = let
    pathList = pkgs.lib.concatMapStringsSep " " (config: config.directory)
      config.services.resilio.sharedFolders;
  in ''
    mkdir -p ${pathList}
    chown rslsync:rslsync -R ${pathList}
  '';

  services.resilio = {
    enable = true;
    enableWebUI = false;
    listeningPort = 18776;
    sharedFolders = let
      dirs = {
        "music" = "readonly";
        "photo" = "readonly";
        "books" = "readwrite";
        "jasper" = "readonly";
        "hiske" = "readonly";
        "hjgames" = "readwrite";
        "gilles1" = "encrypted";
        "gilles4" = "encrypted";
        "gilles5" = "encrypted";
        "gilles6" = "encrypted";
        "gilles7" = "encrypted";
      };
      configFor = dir: perms: {
        secretFile = "/run/secrets/resilio_key_${dir}_${perms}";
        directory = "/srv/volume1/${dir}";
        useRelayServer = false;
        useTracker = true;
        useDHT = true;
        searchLAN = true;
        useSyncTrash = false;
        knownHosts = [ ];
      };
    in builtins.attrValues (builtins.mapAttrs configFor dirs);
  };

  # navidrome
  services.navidrome = {
    enable = true;
    settings = {
      MusicFolder = "/srv/volume1/music";
      Port = 4533;
      BaseUrl = "/music";
      ReverseProxyUserHeader = "Remote-User";
      ReverseProxyWhitelist = "127.0.0.1/32";
    };
  };

  # Caddy
  services.caddy = {
    enable = true;
    email = "letsencrypt@jasperwoudenberg.com";
    config = ''
      :80 {
        respond / `
          <html>
            <head><title>ai-banana</title></head>
            <body>
              <h1>ai-banana</h1>
              <ul>
                <li><a href="/files/">files</a></li>
                <li><a href="/music/">music</a></li>
                <li><a href="/feeds/">feeds</a></li>
                <li><a href="/books/">books</a></li>
                <li><a href="/calendar/">calendar</a></li>
                <li><a href="/paulus/">paulus</a></li>
                <li><a href="http://ai-banana:${
                  toString kobodlPort2
                }">kobo upload</a></li>
                <li><a href="http://ai-banana:${
                  toString config.services.adguardhome.port
                }">ad-blocking</a></li>
              </ul>
            </body>
          </html>
        `

        redir /files /files/
        reverse_proxy /files/* {
          to localhost:${toString webdavPort}
        }

        redir /feeds /feeds/
        reverse_proxy /feeds/* {
          to localhost:${toString yarrPort}
        }

        redir /paulus /paulus/
        handle_path /paulus/* {
          reverse_proxy localhost:${toString paulusPort}
        }

        redir /music /music/
        reverse_proxy /music/* {
          to localhost:${toString config.services.navidrome.settings.Port}
          header_up Remote-User admin
        }

        redir /books /books/
        reverse_proxy /books/* {
          to localhost:${toString config.services.calibre-web.listen.port}
          header_up Authorization admin
          header_up X-Script-Name /books
        }

        redir /calendar /calendar/
        handle_path /calendar/* {
          root * /srv/volume1/hjgames/agenda
          file_server
        }
      }

      :${toString kobodlPort2} {
        reverse_proxy localhost:${toString kobodlPort}
      }
    '';
  };

  # calibre-web
  services.calibre-web = {
    enable = true;
    listen.port = 8083;
    user = "rslsync";
    group = "rslsync";
    options.calibreLibrary = "/srv/volume1/books";
    options.enableBookUploading = true;
    # Documentation on this reverse proxy setup:
    # https://github.com/janeczku/calibre-web/wiki/Setup-Reverse-Proxy
    options.reverseProxyAuth.enable = true;
    options.reverseProxyAuth.header = "Authorization";
  };

  # paulus
  systemd.services.paulus = {
    description = "Paulus";
    after = [ "network-target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "rslsync";
      Group = "rslsync";
      ExecStart = builtins.concatStringsSep " " [
        "${pkgs.paulus}/bin/paulus"
        "--questions /srv/volume1/hjgames/paulus/questions.txt"
        "--output /srv/volume1/hjgames/paulus/results.json"
        "--port ${toString paulusPort}"
      ];
      Restart = "on-failure";
    };
  };

  # web-based filebrowser
  systemd.services.rclone-serve-webdav = {
    description = "Rclone Serve";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "rslsync";
      Group = "rslsync";
      ExecStart = "${pkgs.rclone}/bin/rclone serve http /srv/volume1 --addr :${
          toString webdavPort
        } --read-only --baseurl files/";
      Restart = "on-failure";
    };
  };

  # scanner sftp
  systemd.services.rclone-serve-sftp = {
    description = "Rclone Serve";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      exec ${pkgs.rclone}/bin/rclone serve sftp \
        /srv/volume1/hjgames/scans-to-process \
        --key /run/secrets/ssh-key \
        --user sftp \
        --pass "$RCLONE_PASS" \
        --addr :2022
    '';
    serviceConfig = {
      Type = "simple";
      User = "rslsync";
      Group = "rslsync";
      Restart = "on-failure";
      EnvironmentFile = "/run/secrets/sftp-password";
    };
  };

  # ocrmypdf
  systemd.paths.ocrmypdf = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    description =
      "Triggers ocrmypdf service when a file is placed in the scans-to-process directory.";
    pathConfig = {
      DirectoryNotEmpty = "/srv/volume1/hjgames/scans-to-process";
      MakeDirectory = true;
    };
  };
  systemd.services.ocrmypdf = {
    enable = true;
    description =
      "Run ocrmypdf on all files in the scans-to-process directory.";
    script = ''
      for file in /srv/volume1/hjgames/scans-to-process/*; do
        # Notify healthchecks.io that we're about to start scanning.
        ${pkgs.curl}/bin/curl --retry 3 https://hc-ping.com/c10a6886-0cb9-4ec5-89fc-b8a2e65dbe1e/start

        # Run ocrmypdf on the scanned file.
        output="$(mktemp -u "/tmp/$(date '+%Y%m%d')_XXXXXX.pdf")"
        ${pkgs.ocrmypdf}/bin/ocrmypdf \
          --output-type pdf \
          --rotate-pages \
          --skip-text \
          --language nld+eng \
          "$file" \
          "$output" \
          && rm "$file" \
          && mv "$output" /srv/volume1/hjgames/documenten

        # Notify healthchecks.io of the status of the previous command.
        ${pkgs.curl}/bin/curl --retry 3 https://hc-ping.com/c10a6886-0cb9-4ec5-89fc-b8a2e65dbe1e/$?
      done
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "rslsync";
      Group = "rslsync";
    };
  };

  # remind
  systemd.timers.generate_remind_calendar = {
    wantedBy = [ "timers.target" ];
    partOf = [ "simple-timer.service" ];
    timerConfig.OnCalendar = "minutely";
  };
  systemd.services.generate_remind_calendar = {
    serviceConfig = {
      Type = "oneshot";
      User = "rslsync";
      Group = "rslsync";
    };
    script = ''
      ${pkgs.remind}/bin/remind -pp12 -m -b1 /srv/volume1/hjgames/agenda \
        | ${pkgs.rem2html}/bin/rem2html \
        > /srv/volume1/hjgames/agenda/index.html
    '';
  };

  # yarr
  systemd.services.yarr = {
    description = "yarr";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      YARR_ADDR = "127.0.0.1:${toString yarrPort}";
      YARR_BASE = "feeds";
      YARR_DB = "/var/lib/yarr/storage.db";
      HOME = "/var/lib/yarr"; # yarr won't start without this.
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.yarr}/bin/yarr";
      Restart = "on-failure";

      # Create a user with access to a /var/lib/yarr state directory.
      DynamicUser = true;
      StateDirectory = "yarr";

      # Restrict files yarr can access.
      TemporaryFileSystem = "/:ro";
      BindPaths = "/var/lib/yarr";
      BindReadOnlyPaths = "/nix/store";

      # Various security settings, via `systemd-analyze security yarr`.
      CapabilityBoundingSet = "";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      PrivateDevices = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      RestrictAddressFamilies = "AF_UNIX AF_INET";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [ "@system-service" "~@privileged @resources" ];
    };
  };

  # adguard
  services.adguardhome = { enable = true; };

  # backup /var/lib
  systemd.timers.backup_var_lib = {
    wantedBy = [ "timers.target" ];
    partOf = [ "simple-timer.service" ];
    timerConfig.OnCalendar = "hourly";
  };
  systemd.services.backup_var_lib = {
    serviceConfig = { Type = "oneshot"; };
    script = ''
      ${pkgs.rsync}/bin/rsync --archive --human-readable --partial --delete \
        /var/lib \
        /srv/volume1/varlib.backup
    '';
  };

  # kobodl
  virtualisation.oci-containers.containers.kobodl = {
    # configDir = pkgs.writeTextDir "config/kobodl.json" ''
    #   {
    #     "users": [];
    #     "calibre_web": {
    #       "enabled" = true,
    #       "url" = "localhost/books/upload",
    #       "username" = "",
    #       "password" = ""
    #     }
    #   }
    # '';
    image = "ghcr.io/subdavis/kobodl:latest";
    autoStart = true;
    extraOptions = [ "--network=host" ];
    ports = [ "${toString kobodlPort}:${toString kobodlPort}" ];
    volumes = [ "/srv/volume1/kobodl:/kobodl" ];
    cmd = [
      "--config"
      "/kobodl/kobodl.json"
      "serve"
      "--host"
      "0.0.0.0"
      "--port"
      "${toString kobodlPort}"
    ];
  };
}
