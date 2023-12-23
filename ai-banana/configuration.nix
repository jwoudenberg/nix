let
  smtpPort = 8025;
  paulusPort = 8081;
  yarrPort = 8086;
  syncthingPort = 8089;
  adguardHomePort = 8090;
  boodschappenPort = 8091;
  uids = {
    rclone_serve_sftp = 9;
  };
in
{ pkgs, config, modulesPath, flakeInputs, ... }: {

  users.users.jasper.extraGroups = [ "gonic" "syncthing" ];

  systemd.tmpfiles.rules = [
    "d /persist 0700 root root - -"

    # Don't try to set permissions for files inside syncthing directories,
    # it will lead to an edit war between syncthing clients.
    "d /persist/jasper 0770 root syncthing - -"
    "d /persist/hjgames 0770 root syncthing - -"
    "d /persist/hiske 0770 root syncthing - -"

    "d /persist/books 0770 root syncthing - -"
    "Z /persist/books ~0770 - syncthing - -"

    "d /persist/music 0750 gonic gonic - -"
    "Z /persist/music ~0750 gonic gonic - -"

    "d /persist/webcalendar 0777 root syncthing - -"

    "d /persist/syncthing 0700 syncthing syncthing - -"
  ];

  system.stateVersion = "23.11";
  networking.hostName = "ai-banana";

  # Hardware
  imports = [
    ../shared/nixos-modules/nix.nix
    ../shared/nixos-modules/users.nix
    ../shared/nixos-modules/zfs.nix
    ./nixos-modules/gonic.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  boot.loader.grub.device = "/dev/sda";
  boot.tmp.cleanOnBoot = true;
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/4bfb0e3a-8710-43b8-a5db-cbfe114b3932";
    fsType = "ext4";
  };
  fileSystems."/persist" = {
    device = "trunk/volume1";
    fsType = "zfs";
    neededForBoot = true;
  };
  fileSystems."/var/lib/tailscale" = {
    device = "/persist/tailscale";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
    neededForBoot = true;
  };
  fileSystems."/var/lib/private/yarr" = {
    device = "/persist/yarr";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
    neededForBoot = true;
  };

  # Enable IP forwarding to allow this machine to function as a tailscale exit
  # node.
  # See: https://tailscale.com/kb/1104/enable-ip-forwarding/
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

  # Packages
  environment.systemPackages = [ ];

  # Tailscale
  services.tailscale = {
    enable = true;
    permitCertUid = "syncthing";
  };

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  programs.mosh.enable = true;

  # Network
  networking.hostId = "981a793c";
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedTCPPorts = [
      22 # ssh admin
      2022 # ssh printserver
    ];
    allowedUDPPorts = [
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
      ls -1qA /persist/hjgames/scans-to-process/ | grep -q . || \
        ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 -o /dev/null \
        https://hc-ping.com/8ff8704b-d08e-47eb-b879-02ddb7442fe2

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
      check_free_diskspace '/persist'
    '';
  };

  # syncthing
  systemd.services.syncthing.serviceConfig = {
    RuntimeDirectory = "syncthing";
    BindPaths = [
      "/run/syncthing:/persist"
      "/persist/jasper"
      "/persist/hiske"
      "/persist/hjgames"
      "/persist/syncthing"
    ];
    UMask = "0007";
  };
  systemd.services.syncthing-init.serviceConfig = {
    BindPaths = [ "/run/syncthing-init:/persist" "/persist/syncthing" ];
  };
  services.syncthing = {
    enable = true;
    settings = {
      gui.insecureSkipHostcheck = true;
      options = {
        relaysEnabled = false;
        natEnabled = false;
        globalAnnounceEnabled = false;
        localAnnounceEnabled = false;
        urAccepted = -1;
      };
      folders = {
        "jasper" = {
          path = "/persist/jasper";
          devices = [
            "fragile-walrus"
            "sentient-tshirt"
            "fragile-walrus-popos"
            "sentient-tshirt-popos"
          ];
        };
        "hjgames" = {
          path = "/persist/hjgames";
          devices = [
            "fragile-walrus"
            "sentient-tshirt"
            "hiske-macbook"
            "fragile-walrus-popos"
            "sentient-tshirt-popos"
            "klarinet"
          ];
        };
        "hiske" = {
          path = "/persist/hiske";
          devices = [ "hiske-macbook" "klarinet" ];
        };
      };
      devices = {
        "fragile-walrus" = {
          id = "ZKTWYFA-UHXFVSQ-J2NVTBT-PFQQUBE-DLRMWUG-3DVNWQK-LMSGYKB-ZEIAOQ7";
          addresses = [ "tcp://fragile-walrus" ];
        };
        "sentient-tshirt" = {
          id = "NQANURT-2P4WV4U-J72CBNC-2PB2NTQ-3TIA7RE-W222D6W-4UN7UTF-225KBAZ";
          addresses = [ "tcp://sentient-tshirt" ];
        };
        "fragile-walrus-popos" = {
          id = "6PKKRT3-RPXREZA-ACMHNLY-SID2S7W-NRUKKOW-NUMT2FZ-7ZKWJ24-X7HHOA6";
          addresses = [ "tcp://fragile-walrus-popos" ];
        };
        "sentient-tshirt-popos" = {
          id = "QFOYAFG-SUFCHOW-RK7MEKB-5FBY7OE-DSDFLGR-UMVHI6O-HBMMBD3-HA4X3A4";
          addresses = [ "tcp://sentient-tshirt-popos" ];
        };
        "hiske-macbook" = {
          id = "X6P3C6P-RTXOTRN-SVAPQ3T-4ZFB6FM-TTZVYJF-ZKDE3PG-5JAFJ6L-VYBRHQC";
          addresses = [ "tcp://hiske-macbook" ];
        };
        "klarinet" = {
          id = "W3G65QI-CEWVZ4R-ZBBH4R4-2IF4WZS-WWEOAS3-WWC2UCR-JRITAEG-XHTAIAK";
          addresses = [ "tcp://klarinet" ];
        };
      };
    };
    overrideFolders = true;
    overrideDevices = true;
    dataDir = "/persist";
    configDir = "/persist/syncthing";
    guiAddress = "127.0.0.1:${toString syncthingPort}";
  };

  # Caddy
  systemd.services.caddy.serviceConfig.BindReadOnlyPaths = [
    "/persist/webcalendar:/run/agenda"
    "/persist/hjgames:/run/hjgames"
  ];
  services.caddy = {
    enable = true;
    user = "syncthing";
    email = "letsencrypt@jasperwoudenberg.com";
    extraConfig = ''
      http://${config.networking.hostName}:80 {
        redir https://ai-banana.panther-trout.ts.net{uri} permanent
      }

      https://ai-banana.panther-trout.ts.net {
        tls {
          get_certificate tailscale
        }

        route / {
          header +Content-Type "text/html; charset=utf-8"
          respond `${pkgs.lib.readFile ./index.html}`
        }

        redir /files /files/
        handle_path /files/* {
          root * /run/hjgames
          file_server browse
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
        handle_path /music/* {
          reverse_proxy ${toString config.services.gonic.settings.listen-addr}
        }

        redir /books /books/
        reverse_proxy /books/* {
          to localhost:${toString config.services.calibre-web.listen.port}
          header_up Authorization admin
          header_up X-Script-Name /books
        }

        redir /calendar /calendar/
        handle_path /calendar/* {
          root * /run/agenda
          file_server
        }

        redir /boodschappen /boodschappen/
        reverse_proxy /boodschappen/* {
          to localhost:${toString boodschappenPort}
        }

        redir /syncthing /syncthing/
        handle_path /syncthing/* {
          reverse_proxy localhost:${toString syncthingPort}
        }
      }
    '';
  };

  # calibre-web
  systemd.services.calibre-web.serviceConfig.BindPaths =
    [ "/persist/books:/run/books" ];
  services.calibre-web = {
    enable = true;
    group = "syncthing";
    listen.port = 8083;
    options.calibreLibrary = "/run/books";
    options.enableBookUploading = true;
    # Documentation on this reverse proxy setup:
    # https://github.com/janeczku/calibre-web/wiki/Setup-Reverse-Proxy
    options.reverseProxyAuth.enable = true;
    options.reverseProxyAuth.header = "Authorization";
  };

  # paulus
  systemd.services.paulus = {
    description = "Paulus";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "syncthing";
      Restart = "on-failure";
      RuntimeDirectory = "paulus";
      RootDirectory = "/run/paulus";
      BindReadOnlyPaths = [ builtins.storeDir ];
      BindPaths = [ "/persist/hjgames/paulus" ];
    };
    script = ''
      exec ${pkgs.paulus}/bin/paulus \
        --questions /persist/hjgames/paulus/questions.txt \
        --output /persist/hjgames/paulus/results.json \
        --port ${toString paulusPort}
    '';
  };

  # scanner sftp
  users.users.rclone_serve_sftp = {
    uid = uids.rclone_serve_sftp;
    group = "syncthing";
    isSystemUser = true;
  };
  systemd.services.rclone-serve-sftp = {
    description = "Rclone Serve";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      exec ${pkgs.rclone}/bin/rclone serve sftp \
        /persist/hjgames/scans-to-process \
        --key "$CREDENTIALS_DIRECTORY/ssh-key" \
        --user sftp \
        --pass "$(cat "$CREDENTIALS_DIRECTORY/sftp-password")" \
        --addr :2022
    '';
    serviceConfig = {
      Type = "simple";
      User = uids.rclone_serve_sftp;
      UMask = "007";
      Restart = "on-failure";
      RuntimeDirectory = "rclone_serve_sftp";
      RootDirectory = "/run/rclone_serve_sftp";
      BindReadOnlyPaths = [ builtins.storeDir ];
      BindPaths = [ "/persist/hjgames/scans-to-process" ];
      LoadCredential = [
        "ssh-key:/persist/credentials/ssh-key"
        "sftp-password:/persist/credentials/sftp-password"
      ];
    };
  };

  systemd.paths.ocrmypdf = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    description =
      "Triggers ocrmypdf service when a file is placed in the scans-to-process directory.";
    pathConfig = {
      DirectoryNotEmpty = "/persist/hjgames/scans-to-process";
      MakeDirectory = true;
    };
  };
  systemd.services.ocrmypdf = {
    enable = true;
    description =
      "Run ocrmypdf on all files in the scans-to-process directory.";
    script = ''
      for file in /persist/hjgames/scans-to-process/*; do
        # Notify healthchecks.io that we're about to start scanning.
        ${pkgs.curl}/bin/curl --retry 3 https://hc-ping.com/c10a6886-0cb9-4ec5-89fc-b8a2e65dbe1e/start

        # Run ocrmypdf on the scanned file.
        output="$(${pkgs.coreutils}/bin/mktemp -u "/tmp/$(date '+%Y%m%d')_XXXXXX.pdf")"
        ${pkgs.ocrmypdf}/bin/ocrmypdf \
          --output-type pdf \
          --rotate-pages \
          --skip-text \
          --language nld+eng \
          "$file" \
          "$output" \
          && rm "$file" \
          && mv "$output" /persist/hjgames/documenten

        # Notify healthchecks.io of the status of the previous command.
        ${pkgs.curl}/bin/curl --retry 3 https://hc-ping.com/c10a6886-0cb9-4ec5-89fc-b8a2e65dbe1e/$?
      done
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "syncthing";
      UMask = "007";
      PrivateTmp = true;
      RuntimeDirectory = "ocrmypdf";
      RootDirectory = "/run/ocrmypdf";
      BindReadOnlyPaths = [
        builtins.storeDir
        # For curl-ing https:// endponits
        "${
          config.environment.etc."ssl/certs/ca-certificates.crt".source
        }:/etc/ssl/certs/ca-certificates.crt"
        "/etc"
      ];
      BindPaths =
        [ "/persist/hjgames/scans-to-process" "/persist/hjgames/documenten" ];
      LoadCredential = [
        "ssh-key:/persist/credentials/ssh-key"
        "sftp-password:/persist/credentials/sftp-password"
      ];
    };
  };

  # remind
  systemd.timers.generate_agenda = {
    wantedBy = [ "timers.target" ];
    partOf = [ "simple-timer.service" ];
    timerConfig.OnCalendar = "minutely";
  };
  systemd.services.generate_agenda = {
    serviceConfig = {
      Type = "oneshot";
      User = "syncthing";
      RuntimeDirectory = "generate_agenda";
      RootDirectory = "/run/generate_agenda";
      BindReadOnlyPaths = [ builtins.storeDir "/persist/hjgames/agenda" ];
      BindPaths = [ "/persist/webcalendar" ];
    };
    script = ''
      cat /persist/hjgames/agenda/*agenda.txt \
        | ${pkgs.agenda-txt}/bin/agenda-txt --html *12m \
        > /persist/webcalendar/index.html
    '';
  };

  # fdm
  systemd.timers.fdm = {
    wantedBy = [ "timers.target" ];
    partOf = [ "simple-timer.service" ];
    timerConfig.OnCalendar = "minutely";
  };
  systemd.services.fdm = {
    description = "fdm";
    serviceConfig = {
      Type = "oneshot";
      User = "syncthing";
      StateDirectory = "fdm";
      WorkingDirectory = "/var/lib/fdm";
      RuntimeDirectory = "fdm";
      RootDirectory = "/run/fdm";
      PrivateTmp = true;
      BindReadOnlyPaths = [
        builtins.storeDir
        "/etc" # Needed for getting info about current user with getpwuid
        "/bin" # fdm calls /bin/sh to run $(..) and %(..) commands in config
      ];
      BindPaths = [ "/persist/jasper/email/INBOX" ];
      LoadCredential =
        [ "freedom_imap_password:/persist/credentials/freedom_imap_password" ];
    };
    script =
      let
        fdmConfigFile = pkgs.writeTextFile {
          name = "fdm.conf";
          text = ''
            set lock-file "/var/lib/fdm/fdm.lock"
            set file-umask 002

            account "freedom" imaps
              server "imap.freedom.nl"
              port 993
              user "jwoudenberg@freedom.nl"
              pass $(${pkgs.coreutils}/bin/cat "$CREDENTIALS_DIRECTORY/freedom_imap_password")
              folders { "INBOX" "Spam" }
              no-cram-md5

            action "fetch"
              maildir "/persist/jasper/email/INBOX"

            match all action "fetch"
          '';
        };
      in
      ''
        ${pkgs.fdm}/bin/fdm -vv -f ${fdmConfigFile} fetch
        ${pkgs.curl}/bin/curl --retry 3 https://hc-ping.com/f4f0e24f-9d45-4191-96b6-914759ef4bb2/$?
      '';
  };

  # smtprelay
  systemd.services.smtprelay = {
    description = "smtprelay";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      SMTP_PASS=$(cat "$CREDENTIALS_DIRECTORY/freedom_smtp_password")
      ${pkgs.smtprelay}/bin/smtprelay \
        -listen "0.0.0.0:${toString smtpPort}" \
        -allowed_nets "100.64.0.0/10" \
        -remotes "smtps://jwoudenberg@freedom.nl:$SMTP_PASS@smtp.freedom.nl"
    '';
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      LoadCredential =
        [ "freedom_smtp_password:/persist/credentials/freedom_smtp_password" ];

      # Various security settings, via `systemd-analyze security yarr`.
      DynamicUser = true;
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
      SystemCallFilter = [ "@system-service" ];
    };
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
    };
  };

  # boodschappen
  systemd.services.boodschappen = {
    description = "boodschappen";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      PORT = toString boodschappenPort;
      TODO_TXT_PATH = "/persist/hjgames/boodschappen/groceries.txt";
      TITLE = "Boodschappen";
    };
    serviceConfig = {
      Type = "simple";
      User = "syncthing";
      ExecStart = "${pkgs.todo-txt-web}/bin/todo-txt-web";
      Restart = "on-failure";
      RuntimeDirectory = "boodschappen";
      RootDirectory = "/run/boodschappen";
      BindReadOnlyPaths = [ builtins.storeDir ];
      BindPaths = [ "/persist/hjgames/boodschappen" ];
    };
  };

  # adguard
  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    settings = {
      http = {
        address = "0.0.0.0:${toString adguardHomePort}";
      };
      schema_version = 12;
      users = [ ];
      dns = {
        bind_hosts = [ "100.118.235.97" ];
        port = 53;
        protection_enabled = true;
        filtering_enabled = true;
        parental_enabled = false;
        safesearch_enabled = false;
        safebrowsing_enabled = false;
        upstream_dns = [ "https://dns10.quad9.net/dns-query" ];
        bootstrap_dns =
          [ "9.9.9.10" "149.112.112.10" "2620:fe::10" "2620:fe::fe:10" ];
        querylog_enabled = true;
        querylog_file_enabled = false;
      };
      dhcp.enabled = false;
      tls.enabled = false;
    };
  };

  # zrepl
  services.zrepl = {
    enable = true;
    settings = {
      jobs = [{
        type = "snap";
        name = "volume1_backups";
        filesystems = {
          "trunk" = false;
          "trunk/volume1" = true;
        };
        snapshotting = {
          type = "periodic";
          prefix = "zrepl_";
          interval = "10m";
          hooks = [{
            type = "command";
            timeout = "30s";
            err_is_fatal = false;
            path =
              let
                script = pkgs.writeShellApplication {
                  name = "zrepl-healthchecks-update";
                  text = ''
                    if [ "$ZREPL_HOOKTYPE" != "post_snapshot" ]; then exit 0; fi
                    if [ "$ZREPL_DRYRUN" == "true" ]; then exit 0; fi
                    ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 \
                      --data-raw "$ZREPL_FS: $ZREPL_SNAPNAME" \
                      https://hc-ping.com/97cfd67a-ff76-43d6-bebd-511847e0f6d5
                  '';
                };
              in
              "${script}/bin/zrepl-healthchecks-update";
          }];
        };
        pruning = {
          keep = [{
            type = "grid";
            regex = ".*";
            grid = "1x1h(keep=all) | 24x1h | 6x1d | 4x7d | 120x30d";
          }];
        };
      }];
    };
  };
}
