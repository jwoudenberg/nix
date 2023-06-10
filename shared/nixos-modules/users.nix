{ pkgs, ... }: {
  users.mutableUsers = false;
  users.users.jasper = {
    isNormalUser = true;
    home = "/home/jasper";
    extraGroups = [ "wheel" "syncdata" "sway" "ic2" ];
    hashedPassword =
      "$y$j9T$lhBW.HPXfrhWgqf6V5yoi/$j5O92DHx/DNk4TjwXP4N1SDOzdt1n0T8ALeRdJki2QD";
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPm2jdW8FNbI0lwVWbJBJXU8Ib1GVZRhY6Sy10hZFlSobt2RChtPBAUV/WNsG+Cb7jjtNnrHZWKJnO9mvClfg6c="
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCpYScAJfuGpIjYWS1Xf02y5jVFmXD3fsZ0rv364N2uHEKpt7YHaiWX+vCOaNf3j6pW9CPp7jtf/+udwtcXrcb4="
    ];
    uid = 1000;
  };

  security.sudo.extraConfig = ''
    Defaults lecture=never
  '';
}
