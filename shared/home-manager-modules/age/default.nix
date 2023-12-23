{ pkgs, config, ... }: {
  home.packages =
    let
      wrappedPassage = pkgs.writeShellScriptBin "passage" ''
        export PASSAGE_DIR="${config.home.homeDirectory}/docs/password-store"
        export PASSAGE_IDENTITIES_FILE=${./identities}
        export PASSAGE_RECIPIENTS_FILE=${./recipients}
        exec ${pkgs.passage}/bin/passage "$@"
      '';
    in
    [ pkgs.age pkgs.age-plugin-yubikey wrappedPassage ];
}
