# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ];

  hardware.cpu.intel.updateMicrocode = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 10;

  networking.hostName = "jasper-desktop-nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    with pkgs; [
    (callPackage ./pkgs/gnupg.nix { })
    (callPackage ./pkgs/neovim.nix { })
    (callPackage ./pkgs/pass.nix { })
    cabal2nix
    calibre
    docker
    dmenu
    efibootmgr
    feh
    firefox
    fish
    fzf
    git
    handbrake
    i3
    i3status
    nodePackages.node2nix
    pavucontrol
    python27Packages.neovim
    python35Packages.neovim
    ripgrep
    sakura
    unzip
    vlc
    xclip
    xsel
  ];

  programs.fish.enable = true;

  environment.variables.EDITOR = "nvim";
  environment.variables.FZF_DEFAULT_COMMAND = "rg --files";
  # List services that you want to enable:

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "ctrl:nocaps";
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.windowManager.i3.enable = true;

  # Enable resilio sync
  services.resilio.enable = true;
  services.resilio.deviceName = "jasper-desktop-nixos";
  services.resilio.enableWebUI = true;
  services.resilio.httpListenPort = 8888;

  # Enable pcscd for Yubikey support.
  services.pcscd.enable = true;

  # Enable docker.
  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.jasper = {
    isNormalUser = true;
    home = "/home/jasper";
    extraGroups = [ "wheel" "rslsync" "docker" ];
    uid = 1000;
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.03";
  system.autoUpgrade.enable = true;
}
