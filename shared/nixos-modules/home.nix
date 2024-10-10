{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.homedir.files = lib.mkOption {
    default = { };
    type = lib.types.attrsOf (
      lib.types.oneOf [
        lib.types.str
        lib.types.pathInStore
      ]
    );
    example = lib.literalExpression ''
      {
        ".config/nvim/init.lua" = ./init.lua;
        ".config/git/ignore" = ./gitignore";
      }
    '';
    description = "Files to be linked into the homedirectory.";
  };

  config = {
    # Script adapted from home-manager.
    systemd.services.init-home = {
      description = "Initialization of home directory";
      wantedBy = [ "multi-user.target" ];
      wants = [ "nix-daemon.socket" ];
      after = [ "nix-daemon.socket" ];
      before = [ "systemd-user-sessions.service" ];

      unitConfig = {
        RequiresMountsFor = "/home/jasper";
      };

      stopIfChanged = false;

      serviceConfig = {
        User = "jasper";
        Type = "oneshot";
        RemainAfterExit = "yes";
        TimeoutStartSec = "5m";

        ExecStart =
          let
            linkCommands = builtins.map (
              homepath:
              let
                sourcepath = builtins.getAttr homepath config.homedir.files;
              in
              ''
                mkdir -p "/home/jasper/${builtins.dirOf homepath}"
                ln -Tsf "${sourcepath}" "/home/jasper/${homepath}"
              ''
            ) (builtins.attrNames config.homedir.files);
          in
          pkgs.writeScript "init-home" ''
            #! ${pkgs.runtimeShell} -el
            ${builtins.concatStringsSep "\n" linkCommands}
          '';
      };
    };
  };

  options.homedir.sessionVariables = lib.mkOption {
    default = { };
    type = lib.types.attrsOf lib.types.str;
    example = lib.literalExpression ''
      {
        "EDITOR" = "nvim";
      }
    '';
    description = "Variables to set in the shell session";
  };
}
