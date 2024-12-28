{
  pkgs,
  config,
  lib,
  home-manager,
  flakeInputs,
  ...
}:

{
  imports = [
    ../modules/home.nix
    ../modules/installed-apps.nix
    ../modules/ghostty.nix
    ../modules/localization.nix
    ../modules/networking.nix
    ../modules/nix.nix
    ../modules/persist-linking.nix
    ../modules/pipewire.nix
    ../modules/screengrab.nix
    ../modules/ssh.nix
    ../modules/sway.nix
    ../modules/syncthing.nix
    ../modules/systemd-boot.nix
    ../modules/users.nix
    ../modules/wifi.nix
    ./hardware-configuration.nix
  ];

  specialisation.work.configuration = import ./specialisation-work.nix {
    pkgs = pkgs;
    lib = lib;
    config = config;
  };

  hardware.graphics.extraPackages = [
    pkgs.vaapiIntel
    pkgs.libvdpau-va-gl
    pkgs.intel-media-driver
  ];
  hardware.enableRedistributableFirmware = true;
  environment.variables.VDPAU_DRIVER = lib.mkDefault "va_gl";

  boot.initrd.systemd.enable = true;
  boot.resumeDevice = "/dev/disk/by-uuid/736ad098-99be-49c7-8af5-3772c9421128";
  boot.initrd.luks.devices.crypted = {
    device = "/dev/disk/by-uuid/7f495c9a-8ee9-4f31-ab35-e91000524639";
    preLVM = true;
  };
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;
  boot.kernelParams = [
    # Without this sway won't find the GPU
    "i915.force_probe=4626"
  ];

  # This enables the brightness keys to work
  # https://community.frame.work/t/12th-gen-not-sending-xf86monbrightnessup-down/20605/11
  boot.blacklistedKernelModules = [ "hid-sensor-hub" ];

  # Mis-detected by nixos-generate-config
  # https://github.com/NixOS/nixpkgs/issues/171093
  # https://wiki.archlinux.org/title/Framework_Laptop#Changing_the_brightness_of_the_monitor_does_not_work
  hardware.acpilight.enable = lib.mkDefault true;

  # Power management and saving
  powerManagement.enable = true;
  services.thermald.enable = true;
  services.auto-cpufreq.enable = true;
  services.logind.lidSwitch = "hibernate";

  networking.hostId = "bbc4755f";

  networking.hostName = "sentient-tshirt";

  programs.command-not-found.enable = false;

  services.fwupd.enable = true;
  services.udisks2.enable = true;

  system.stateVersion = "24.11";
  system.autoUpgrade.enable = false;
}
