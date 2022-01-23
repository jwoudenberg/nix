# Fork of the xandikos module in Nixpkgs, because I want to customize the
# location directory xandikos uses.
#
# Original here:
# https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/xandikos.nix

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.xandikos;
in {

  options = {
    services.xandikos = {
      enable = mkEnableOption "Xandikos CalDAV and CardDAV server";

      package = mkOption {
        type = types.package;
        default = pkgs.xandikos;
        defaultText = literalExpression "pkgs.xandikos";
        description = "The Xandikos package to use.";
      };

      address = mkOption {
        type = types.str;
        default = "localhost";
        description = ''
          The IP address on which Xandikos will listen.
          By default listens on localhost.
        '';
      };

      port = mkOption {
        type = types.port;
        default = 8080;
        description = "The port of the Xandikos web application";
      };

      routePrefix = mkOption {
        type = types.str;
        default = "/";
        description = ''
          Path to Xandikos.
          Useful when Xandikos is behind a reverse proxy.
        '';
      };

      directory = mkOption {
        type = types.str;
        default = "/var/lib/xandikos";
        description = ''
          The directory xandikos will use for storing data.
        '';
      };

      extraOptions = mkOption {
        default = [ ];
        type = types.listOf types.str;
        example = literalExpression ''
          [ "--autocreate"
            "--defaults"
            "--current-user-principal user"
            "--dump-dav-xml"
          ]
        '';
        description = ''
          Extra command line arguments to pass to xandikos.
        '';
      };

    };

  };

  config = mkIf cfg.enable (mkMerge [{

    users.users.xandikos = {
      isSystemUser = true;
      group = "xandikos";
    };
    users.groups.xandikos = { };

    systemd.services.xandikos = {
      description = "A Simple Calendar and Contact Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = "xandikos";
        Group = "xandikos";
        RuntimeDirectory = "xandikos";
        PrivateDevices = true;
        # Sandboxing
        CapabilityBoundingSet = "CAP_NET_RAW CAP_NET_ADMIN";
        ProtectSystem = "full";
        ProtectHome = true;
        PrivateTmp = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies =
          "AF_INET AF_INET6 AF_UNIX AF_PACKET AF_NETLINK";
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        ExecStart = ''
          ${cfg.package}/bin/xandikos \
            --directory ${cfg.directory} \
            --listen-address ${cfg.address} \
            --port ${toString cfg.port} \
            --route-prefix ${cfg.routePrefix} \
            ${lib.concatStringsSep " " cfg.extraOptions}
        '';
      };
    };
  }]);
}
