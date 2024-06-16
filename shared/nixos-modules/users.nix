{ pkgs, ... }:
{
  users.mutableUsers = false;
  users.users.jasper = {
    isNormalUser = true;
    home = "/home/jasper";
    extraGroups = [
      "wheel"
      "syncdata"
      "sway"
      "ic2"
    ];
    hashedPassword = "$y$j9T$lhBW.HPXfrhWgqf6V5yoi/$j5O92DHx/DNk4TjwXP4N1SDOzdt1n0T8ALeRdJki2QD";
    openssh.authorizedKeys.keys = [
      # Yubikey 5 NFC
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAICX1KxUJWwIscXsNGnb778Q/nhbg8ir8K0iXZFDsQEzkAAAADnNzaDpZdWJpa2V5U1NI"
      # Yubikey 5 USB-C
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINiA5SYUntSswrkNAdP6t5uiIEI/rIgjAuUMmKVluAcnAAAABHNzaDo="
    ];
    uid = 1000;
  };

  security.sudo-rs = {
    enable = true;
  };
}
