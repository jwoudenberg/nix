{ pkgs, ... }: {
  users.mutableUsers = false;
  users.users.jasper = {
    isNormalUser = true;
    home = "/home/jasper";
    extraGroups = [ "wheel" "syncdata" "sway" "ic2" ];
    hashedPassword =
      "$y$j9T$lhBW.HPXfrhWgqf6V5yoi/$j5O92DHx/DNk4TjwXP4N1SDOzdt1n0T8ALeRdJki2QD";
    openssh.authorizedKeys.keys = [
      # Yubikey 5 NFC
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPm2jdW8FNbI0lwVWbJBJXU8Ib1GVZRhY6Sy10hZFlSobt2RChtPBAUV/WNsG+Cb7jjtNnrHZWKJnO9mvClfg6c="
      # Yubikey 5 USB-C
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLudn9N7mU+ZJTKxgpcPilXGCP1tfoAqg/gy0uT/ZiDiuaz8c83wJqAPBmWKAHGcFDcRbaQLmnnYaYkHHJ9L6xU="
    ];
    uid = 1000;
  };

  security.sudo-rs = { enable = true; };
}
