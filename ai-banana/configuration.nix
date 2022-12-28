let
  smtpPort = 8025;
  webdavPort = 8080;
  paulusPort = 8081;
  kobodlPort = 8084;
  kobodlPort2 = 8085;
  yarrPort = 8086;
  todoTxtWebPort = 8088;
  adguardHomePort = 8090;
in { pkgs, config, modulesPath, flakeInputs, ... }: {

  # Nix
  system.stateVersion = "22.11";
  networking.hostName = "ai-banana";

  # Hardware
  disabledModules = [ "services/networking/resilio.nix" ];
  imports = [
    ../shared/nixos-modules/nix.nix
    ../shared/nixos-modules/resilio.nix
    ../shared/nixos-modules/users.nix
    ../shared/nixos-modules/zfs.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  boot.loader.grub.device = "/dev/sda";
  boot.cleanTmpDir = true;
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/4bfb0e3a-8710-43b8-a5db-cbfe114b3932";
    fsType = "ext4";
  };
  fileSystems."/persist" = {
    device = "trunk/volume1";
    fsType = "zfs";
    neededForBoot = true;
  };
  fileSystems."/var/lib/private/navidrome" = {
    device = "/persist/navidrome";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
    neededForBoot = true;
  };
  fileSystems."/var/lib/resilio-sync" = {
    device = "/persist/resilio-sync";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
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
    permitCertUid = "caddy";
  };

  # SSH
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
  };
  programs.mosh.enable = true;

  # Network
  networking.hostId = "981a793c";
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
      ls -1qA /persist/hjgames/scans-to-process/ | grep -q . || \
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
      check_free_diskspace '/persist'
    '';
  };

  # Resilio Sync
  system.activationScripts.mkResilioSharedFolders = let
    pathList = pkgs.lib.concatMapStringsSep " " (config: config.directory)
      config.services.resilio.sharedFolders;
  in ''
    mkdir -p ${pathList}
    chown rslsync:rslsync ${pathList}
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
        "jasper" = "readwrite";
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
        directory = "/persist/${dir}";
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
      MusicFolder = "/persist/music";
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
    extraConfig = ''
      http://${config.networking.hostName}:80 {
        redir https://ai-banana.panther-trout.ts.net{uri} permanent
      }

      https://ai-banana.panther-trout.ts.net {
        file_server /favicon.ico {
          root ${
            pkgs.runCommand "ai-banana-favicon-dir" { }
            "install -DT ${./favicon.ico} $out/favicon.ico"
          }
        }

        route / {
          header +Content-Type "text/html; charset=utf-8"
          respond `
            <!DOCTYPE html>
            <html>
              <head><title>${config.networking.hostName}</title></head>
              <body>
                <h1>${config.networking.hostName}</h1>
                <ul>
                  <li><a href="/files/">files</a></li>
                  <li><a href="/music/">music</a></li>
                  <li><a href="/feeds/">feeds</a></li>
                  <li><a href="/books/">books</a></li>
                  <li><a href="/calendar/">calendar</a></li>
                  <li><a href="/todos/">todos</a></li>
                  <li><a href="/paulus/">paulus</a></li>
                  <li><a href="http://${config.networking.hostName}:${
                    toString kobodlPort2
                  }">kobo upload</a></li>
                  <li><a href="http://${config.networking.hostName}:${
                    toString adguardHomePort
                  }">ad-blocking</a></li>
                </ul>
                <style>
                  body {
                    font-family: arial, sans-serif;
                    font-size: 1.4em;
                  }
                </style>
              </body>
            </html>
          `
        }

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
          root * /persist/hjgames/agenda
          file_server
        }

        redir /todos /todos/
        reverse_proxy /todos/* {
          to localhost:${toString todoTxtWebPort}
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
    options.calibreLibrary = "/persist/books";
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
      User = "rslsync";
      Group = "rslsync";
      ExecStart = builtins.concatStringsSep " " [
        "${pkgs.paulus}/bin/paulus"
        "--questions /persist/hjgames/paulus/questions.txt"
        "--output /persist/hjgames/paulus/results.json"
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
      ExecStart = "${pkgs.rclone}/bin/rclone serve http /persist --addr :${
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
        /persist/hjgames/scans-to-process \
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
        output="$(mktemp -u "/tmp/$(date '+%Y%m%d')_XXXXXX.pdf")"
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
      ${pkgs.remind}/bin/remind -pp12 -m -b1 /persist/hjgames/agenda \
        | ${pkgs.rem2html}/bin/rem2html \
        > /persist/hjgames/agenda/index.html
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
      User = "rslsync";
      Group = "rslsync";
    };
    script = let
      mbsyncConfigFile = pkgs.writeTextFile {
        name = "fdm.conf";
        text = ''
          account "freedom" imaps
            server "imap.freedom.nl"
            port 993
            user "jwoudenberg@freedom.nl"
            pass $(cat /run/secrets/freedom_imap_password)
            folder "INBOX"
            no-cram-md5

          action "fetch"
            maildir "/persist/jasper/email/INBOX"

          match all action "fetch"
        '';
      };
    in ''
      ${pkgs.fdm}/bin/fdm -vv -f ${mbsyncConfigFile} fetch
      ${pkgs.curl}/bin/curl --retry 3 https://hc-ping.com/f4f0e24f-9d45-4191-96b6-914759ef4bb2/$?
    '';
  };

  # smtprelay
  systemd.services.smtprelay = {
    description = "smtprelay";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.smtprelay}/bin/smtprelay \
        -listen "0.0.0.0:${toString smtpPort}" \
        -allowed_nets "100.64.0.0/10" \
        -remotes "smtps://jwoudenberg@freedom.nl:$SMTP_PASS@smtp.freedom.nl"
    '';
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      EnvironmentFile = "/run/secrets/freedom_smtp_password";

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
      SystemCallFilter = [ "@system-service" "~@privileged @resources" ];
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

  # todo-txt-web
  systemd.services.todo-txt-web = {
    description = "todo.txt web";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      PORT = toString todoTxtWebPort;
      TODO_TXT_PATH = "/persist/hjgames/todo.txt";
      TITLE = "Hiske + Jasper Todos";
    };
    serviceConfig = {
      Type = "simple";
      User = "rslsync";
      Group = "rslsync";
      ExecStart = "${pkgs.todo-txt-web}/bin/todo-txt-web";
      Restart = "on-failure";
    };
  };

  # adguard
  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    host = "0.0.0.0";
    port = adguardHomePort;
    settings = {
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
    volumes = [ "/persist/kobodl:/kobodl" ];
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
            path = let
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
            in "${script}/bin/zrepl-healthchecks-update";
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
