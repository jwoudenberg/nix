# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./modules/desktop-hardware.nix
    ./modules/mullvad-vpn.nix
    <home-manager/nixos>
  ];

  hardware.cpu.intel.updateMicrocode = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = [ pkgs.pkgsi686Linux.libva ];
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 10;

  networking.hostName = "jasper-desktop-nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "FiraCode 16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  nixpkgs.config = import ./nixpkgs-config.nix;
  nix.nixPath = [
    "nixpkgs=http://nixos.org/channels/nixos-19.09/nixexprs.tar.xz"
    "home-manager=https://github.com/rycee/home-manager/archive/release-19.09.tar.gz"
    "nixos-config=/etc/nixos/configuration.nix"
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    docker
    efibootmgr
    home-manager
    pavucontrol
    mullvad-vpn
    steam
  ];

  fonts.fonts = [ pkgs.fira-code ];

  programs.sway.enable = true;

  services.resilio.enable = true;
  services.resilio.deviceName = "jasper-desktop-nixos";
  services.resilio.enableWebUI = true;
  services.resilio.httpListenPort = 8888;

  services.pcscd.enable = true; # For Yubikey support
  virtualisation.docker.enable = true;
  services.mullvad-vpn.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jasper = {
    isNormalUser = true;
    home = "/home/jasper";
    extraGroups = [ "wheel" "rslsync" "docker" "sway" ];
    uid = 1000;
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "19.09";
  system.autoUpgrade.enable = true;
}
