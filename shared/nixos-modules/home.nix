{
  pkgs,
  config,
  lib,
  ...
}:
let
  linkCommands = builtins.map (
    homepath:
    let
      sourcepath = builtins.getAttr homepath config.homedir.files;
    in
    ''
      mkdir -p "$out/${builtins.dirOf homepath}"
      ln -s "${sourcepath}" "$out/${homepath}"
    ''
  ) (builtins.attrNames config.homedir.files);
  homedir = pkgs.runCommand "homedir" { } ''
    mkdir $out;
    ${builtins.concatStringsSep "\n" linkCommands}
  '';
in
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
    # We mount the home derivation at as an overlay file system. Because NixOS
    # currently creates an error when changing the source of an overlay mount,
    # we add a layer indirection where the overlay file system users a static
    # path as its source, and we use a regular bind mount to put the home
    # derivation there. When we change the home derivation it's the bind mount
    # that updates, and NixOS deals with that fine.
    fileSystems."/home/.test.source" = {
      device = "${homedir}";
      fsType = "none";
      options = [ "bind" ];
    };
    fileSystems."/home/test" = {
      fsType = "overlay";
      overlay = {
        lowerdir = [ "/home/.test.source" ];
        upperdir = "/home/.test.upperdir";
        workdir = "/home/.test.workdir";
      };
      depends = [ "/persist/.test.source" ];
    };

    systemd.tmpfiles.rules = [
      "z /home/test 0700 jasper users - -"
      "z /home/.test.upperdir 0700 jasper users - -"
      "z /home/.test.workdir 0700 jasper users - -"
    ];
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
