{ pkgs, config, ... }: {
  home.packages =
    let
      wrappedPassage = pkgs.writeShellScriptBin "pass" ''
        export PASSAGE_DIR="${config.home.homeDirectory}/docs/password-store"
        export PASSAGE_IDENTITIES_FILE="${./identities}"
        export PASSAGE_RECIPIENTS_FILE="${./recipients}"
        exec ${pkgs.passage}/bin/passage "$@"
      '';

      totp = pkgs.writers.writePython3Bin "totp" { libraries = [ pkgs.python3Packages.pyotp ]; } ''
        import pyotp
        import sys
        for line in sys.stdin:
            if line.startswith("otpauth"):
                totp = pyotp.parse_uri(line.strip())
                print(totp.now())
                break
      '';
    in
    [ pkgs.age pkgs.age-plugin-yubikey wrappedPassage totp ];
}
