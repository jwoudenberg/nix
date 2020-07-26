{ config, pkgs, lib, ... }:

let cfg = config.services.filebrowser;
in {
  options.services.filebrowser = {

    enable = lib.mkEnableOption "filebrowser";

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        The path to a filebrowser configuration file.
        The configuration format is documented at: https://filebrowser.org/configuration
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = ''
        The port filebrowser should bind to.
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

  config = lib.mkIf cfg.enable {
    systemd.services.filebrowser = {
      description = "filebrowser";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = "filebrowser";

        ExecStart = pkgs.writeShellScript "start-filebrowser" ''
          ${pkgs.filebrowser}/bin/filebrowser \
            --database /var/lib/filebrowser/filebrowser.db \
            --port ${toString cfg.port} \
            ${
            if (cfg.configFile == null) then
              ""
            else
              "--config ${cfg.configFile}"
            }
        '';

        Restart = "on-failure";
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
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };
  };
}
