{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../shared/nixos-modules/nix.nix
    ../shared/nixos-modules/users.nix
  ];

  boot.kernelParams = [ "console=ttyS0,115200n8" ];
  boot.loader.grub.extraConfig = ''
    serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1
    terminal_input serial
    terminal_output serial
  '';

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device =
    "/dev/disk/by-id/ata-SSE064GMLCC-SBC-2S_C295072701DE00012853";

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = [ pkgs.neovim pkgs.flashrom ];

  # SSH
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
  };
  programs.mosh.enable = true;

  system.stateVersion = "22.11";

  # Networking
  networking.hostName = "airborne-cactus";

  systemd.network = {
    enable = true;
    wait-online = { anyInterface = true; };

    links."10-wan" = {
      matchConfig = {
        MACAddress = "00:0d:b9:5f:c8:f9";
        Type = "ether";
      };
      linkConfig = { Name = "wan"; };
    };
    links."10-opt" = {
      matchConfig = {
        MACAddress = "00:0d:b9:5f:c8:f8";
        Type = "ether";
      };
      linkConfig = { Name = "opt"; };
    };
    links."10-lan1" = {
      matchConfig = {
        MACAddress = "00:0d:b9:5f:c8:fa";
        Type = "ether";
      };
      linkConfig = { Name = "lan1"; };
    };
    links."10-lan2" = {
      matchConfig = {
        MACAddress = "00:0d:b9:5f:c8:fb";
        Type = "ether";
      };
      linkConfig = { Name = "lan2"; };
    };
    links."10-wlan" = {
      matchConfig = {
        MACAddress = "04:f0:21:b2:61:c5";
        Type = "wlan";
      };
      linkConfig = { Name = "wlan"; };
    };
  };

  services.resolved.enable = true;
  services.tailscale.enable = true;

  services.hostapd = {
    enable = false;
    interface = "wlan";
    ssid = "Bergweg beta";
    countryCode = "NL";
    hwMode = "g";
    wpa = false; # Set in extraConfig below, to be able to use a password file.

    # The hostapd.wpa_psk file should contain lines with the following format:
    #    ma:ca:dd:re:ss:00 The Passphrase For Device A
    # The MAC address 00:00:00:00:00:00 works as a wildcard.
    # More info here: https://s3lph.me/automatically-rotating-guest-wifi-passwords-with-hostapd.html
    extraConfig = ''
      wpa=2
      wpa_key_mgmt=WPA-PSK
      wpa_psk_file=/persist/credentials/hostapd.wpa_psk
    '';
  };
}
