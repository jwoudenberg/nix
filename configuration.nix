# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ];

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
    let
    nvim = pkgs.neovim.override {
      vimAlias = true;
      withPython = true;
      withPython3 = true;
      withRuby = true;
      configure = {
        customRC = ''
          source ~/.config/nvim/init.vim
          '';
      };
    };
  pinentry = pkgs.pinentry.override {
    ncurses = pkgs.ncurses;
  };
  gpg = pkgs.gnupg.override {
    libusb = pkgs.libusb;
    pinentry = pinentry;
  };
  pass = pkgs.pass.override {
    xclip = pkgs.xclip;
    xdotool = pkgs.xdotool;
    dmenu = pkgs.dmenu;
    gnupg = gpg;
  };
  in
    with pkgs; [
      ripgrep
      fish
      fzf
      nvim
      python35Packages.neovim
      python27Packages.neovim
      xsel
      efibootmgr
      i3
      i3status
      dmenu
      pass
      gpg
      git
      chromium
      xclip
      unzip
      calibre
    ];

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.jasper = {
    isNormalUser = true;
    home = "/home/jasper";
    extraGroups = [ "wheel" "rslsync" ];
    uid = 1000;
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";
  system.autoUpgrade.enable = true;
}
