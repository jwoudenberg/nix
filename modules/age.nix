{ pkgs, config, ... }:
{

  environment.systemPackages =
    let
      identities = pkgs.writeText "identities" ''
        #       Serial: 16670418, Slot: 1
        #         Name: age identity dddec209
        #      Created: Sat, 23 Dec 2023 11:52:25 +0000
        #   PIN policy: Once   (A PIN is required once per session, if set)
        # Touch policy: Always (A physical touch is required for every decryption)
        #    Recipient: age1yubikey1qtsjeh2zjzp80jgnvy8dasc5wljt8ufdrf2mkgug23vu2n5xktvvz4wqrut
        AGE-PLUGIN-YUBIKEY-16F00UQYZMH0VYZGVAFERX
        #       Serial: 23769429, Slot: 1
        #         Name: age identity 01ae97f7
        #      Created: Fri, 29 Dec 2023 14:12:08 +0000
        #   PIN policy: Once   (A PIN is required once per session, if set)
        # Touch policy: Always (A physical touch is required for every decryption)
        #    Recipient: age1yubikey1qwyvmrtx84un8ks5h8l8s5zuk57vaggdgq9v5gzfl7qwas84yy5kqfejewm
        AGE-PLUGIN-YUBIKEY-12KCK5QVZQXHF0ACTRV9S0
      '';

      recipients = pkgs.writeText "recipients" ''
        #       Serial: 16670418, Slot: 1
        #         Name: age identity dddec209
        #      Created: Sat, 23 Dec 2023 11:52:25 +0000
        #   PIN policy: Once   (A PIN is required once per session, if set)
        # Touch policy: Always (A physical touch is required for every decryption)
        age1yubikey1qtsjeh2zjzp80jgnvy8dasc5wljt8ufdrf2mkgug23vu2n5xktvvz4wqrut
        #       Serial: 23769429, Slot: 1
        #         Name: age identity 01ae97f7
        #      Created: Fri, 29 Dec 2023 14:12:08 +0000
        #   PIN policy: Once   (A PIN is required once per session, if set)
        # Touch policy: Always (A physical touch is required for every decryption)
        age1yubikey1qwyvmrtx84un8ks5h8l8s5zuk57vaggdgq9v5gzfl7qwas84yy5kqfejewm
      '';

      wrappedPassage = pkgs.writeShellScriptBin "pass" ''
        export PASSAGE_DIR="/home/jasper/docs/password-store"
        export PASSAGE_IDENTITIES_FILE="${identities}"
        export PASSAGE_RECIPIENTS_FILE="${recipients}"
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
    [
      pkgs.age
      pkgs.age-plugin-yubikey
      wrappedPassage
      totp
    ];
}
