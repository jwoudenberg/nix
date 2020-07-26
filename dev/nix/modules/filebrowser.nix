{ config, pkgs, lib, ... }:

{
  options.services.filebrowser = {

    enable = lib.mkEnableOption "filebrowser";

    config = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = ''
        Configuration options to set before starting. Must be an attribute set
        containing keys and values that are accepted by the `config set`
        command:

            filebrowser config set --<key>=<value>

        Configuration options that are not provided will be set to the defaults
        specified by the `filebrowser config set` command.

        Example:

            {
              port = 8082;
              "auth.method" = "json";
            }
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether ports should be opened in the firewall for filebrowser.
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "filebrowser";
      description = ''
        User account under which filebrowser runs.
      '';
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "filebrowser";
      description = ''
        Group under which filebrowser runs.
      '';
    };
  };

  config = let

    cfg = config.services.filebrowser;

    port = if cfg.config.port == null then 8080 else cfg.config.port;

    configParams = lib.concatStringsSep " "
      (lib.mapAttrsToList (key: value: "--${key}=${lib.escapeShellArg value}")
      cfg.config);

    filebrowser = "${pkgs.filebrowser}/bin/filebrowser";

    configFile = pkgs.runCommand "filebrowser-config.json" { } ''
      # Create a fresh database with all configurations initialized to defaults.
      ${filebrowser} config init
      # Apply user-defined configuration settings.
      ${filebrowser} config set ${configParams}
      # Export the modified filebrowser configuration.
      ${filebrowser} config export $out
    '';

    in lib.mkIf cfg.enable {

      systemd.services.filebrowser = {
        description = "filebrowser";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;
          StateDirectory = "filebrowser";
          ExecStartPre = "${filebrowser} config import ${configFile}";
          ExecStart = filebrowser;
          Restart = "on-failure";
        };
        environment = {
          FB_DATABASE = "/var/lib/filebrowser/filebrowser.db";
          FB_PORT = builtins.toString port;
        };
      };

      users.users = lib.mkIf (cfg.user == "filebrowser") {
        filebrowser = {
          group = cfg.group;
          uid = 320;
        };

      };

      users.groups =
        lib.mkIf (cfg.group == "filebrowser") { filebrowser = { gid = 320; }; };

      networking.firewall = lib.mkIf cfg.openFirewall {
        allowedTCPPorts = [ port ];
        allowedUDPPorts = [ port ];
      };
    };
}
