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
    fileSystems."/home/test" = {
      fsType = "overlay";
      options = [ "volatile" ];
      overlay = {
        lowerdir = [ "${homedir}" ];
        upperdir = "/tmp/home-upper";
        workdir = "/tmp/home-work";
      };
    };

    systemd.tmpfiles.rules = [
      "z /home/test 0700 jasper users - -"
      "z /tmp/home-upper 0700 jasper users - -"
      "z /tmp/home-work 0700 jasper users - -"
    ];
  };
}
