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

  networking.hostName = "airborne-cactus";

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [ vim ];

  # SSH
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
  };
  programs.mosh.enable = true;

  services.tailscale.enable = true;

  system.stateVersion = "22.11"; # Did you read the comment?
}
