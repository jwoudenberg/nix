{ config, pkgs, lib, ... }:

{
  options.services.filebrowser = {

    enable = lib.mkEnableOption "filebrowser";

    config = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      example = {
        port = 8080;
        "auth.method" = "json";
      };
      description = ''
        Configuration options to set before starting. Must be an attribute set
        containing keys and values that are accepted by the `config set`
        command:

            filebrowser config set --<key>=<value>

        Check the output of `filebrowser config set --help` to see all avaialble
        options and their defaults.
      '';
    };

    users = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = ''
              The name of the user to add.
            '';
          };

          password = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = ''
              The password of the user to add.

              This is going to end up in the nix-store and so isn't very secure.
              Passwords aren't used for the Proxy Header and NoAuth authentication schemes and can be left blank in those cases.
              If you're using the (default) JSON authentication scheme using declarative user management is not recommended.
            '';
          };

          commands = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = ''
              A list of the commands a user can execute.
            '';
          };

          locale = lib.mkOption {
            type = lib.types.str;
            default = "en";
            description = ''
              Locale for the user.
            '';
          };

          lockPassword = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Whether the users password should be locked.
              If locked the user is now allowed to change the password.
            '';
          };

          "perm.admin" = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Whether this user has admin priviliges.
            '';
          };

          "perm.create" = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Whether this user is allowed to create files.
            '';
          };

          "perm.delete" = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Whether this user is allowed to delete files.
            '';
          };

          "perm.download" = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Whether this user is allowed to download files.
            '';
          };

          "perm.execute" = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Whether this user is allowed to execute files.
            '';
          };

          "perm.modify" = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Whether this user is allowed to modify files.
            '';
          };

          "perm.rename" = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Whether this user is allowed to rename files.
            '';
          };

          "perm.share" = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Whether this user is allowed to share files.
            '';
          };

          "scope" = lib.mkOption {
            type = lib.types.str;
            default = ".";
            description = ''
              The root of the directories this user is allowed to see.
            '';
          };

          "sorting.asc" = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Default sort order for this user is ascending.
            '';
          };

          "sorting.by" = lib.mkOption {
            type = lib.types.str;
            default = "name";
            description = ''
              The sorting mode (name, size or modified)
            '';
          };

          "viewMode" = lib.mkOption {
            type = lib.types.str;
            default = "list";
            description = ''
              The view mode for this user.
            '';
          };
        };
      }));
      default = null;
      description = ''
        Declaratively manage users.
        Do not use this option if you manage users through the Web UI.
        If this option is provided then re-applying this configuration will
        delete all users and recreate them according to these specifications.
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

    filebrowser = "${pkgs.filebrowser}/bin/filebrowser";

    # Take an attribute set like this:
    # 
    #     { balloons = 12; greeting = "hi"; }
    # 
    # And turns it into a parameter string that like this:
    #
    #     --balloons=12 --greeting=hi
    toParams = attrs:
      lib.concatStringsSep " "
      (lib.mapAttrsToList (key: value: "--${key}=${renderParamValue value}")
      attrs);

    renderParamValue = val:
      if val == true then
        "true"
      else if val == false then
        "false"
      else
        lib.escapeShellArg val;

    configFile = pkgs.runCommand "filebrowser-config.json" { } ''
      # Create a fresh database with all configurations initialized to defaults.
      ${filebrowser} config init
      # Apply user-defined configuration settings.
      ${filebrowser} config set ${toParams cfg.config}
      # Export the modified filebrowser configuration.
      ${filebrowser} config export $out
    '';

    # Take one of the users defined in the configuration and return the command
    # for updating it to match the configuration provided.
    updateUserCmd = user:
      let
        config = lib.filterAttrs (key: value:
          !(key == "name" || key == "password" || lib.hasPrefix "_" key)) user;
      in ''
        if ${filebrowser} users find ${user.name}; then
          ${filebrowser} users update \
            ${lib.escapeShellArg user.name} \
            --password ${lib.escapeShellArg user.password} \
            ${toParams config}
        else
          ${filebrowser} users add \
            ${lib.escapeShellArg user.name} \
            ${lib.escapeShellArg user.password} \
            ${toParams config}
        fi
      '';

    # A script that updates filebrowser users to match the user configuration.
    # We cannot delete and recreate users because then any files shared by users
    # will be deleted.
    initUsers = if cfg.users == null then
      ""
    else ''
      # Update users defined in configuration.
      ${lib.concatStringsSep "\n" (builtins.map updateUserCmd cfg.users)}

      # Delete users not defined in configuration.
      target_user_names=(${
        lib.concatStringsSep " "
        (builtins.map (user: lib.escapeShellArg (user.name)) cfg.users)
      })
      target_user_ids=()
      for name in "''${target_user_names[@]}"
      do
        matching_id=$(${filebrowser} users find $name | cut -d ' ' -f1 | tail -n +2) 
        target_user_ids+=($matching_id)
      done

      # Delete users not defined in the configuration.
      all_user_ids=$(${filebrowser} users ls | cut -d ' ' -f1 | tail -n +2)
      for id in $all_user_ids
      do
        if [[ ! " ''${target_user_ids[@]} " =~ " ''${id} " ]]; then
          ${filebrowser} users rm "$id"
        fi
      done
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
          ExecStartPre = pkgs.writeShellScript "filebrowser-prestart" ''
            #!${pkgs.bash}/bin/bash
            set -euxo pipefail
            ${filebrowser} config import ${configFile}
            ${initUsers}
          '';
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
