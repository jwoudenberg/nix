{ pkgs, config, lib, home-manager, flakeInputs, ... }:

{
  imports = [
    ../shared/nixos-modules/localization.nix
    ../shared/nixos-modules/pipewire.nix
    ../shared/nixos-modules/networking.nix
    ../shared/nixos-modules/nix.nix
    ../shared/nixos-modules/resilio-custom.nix
    ../shared/nixos-modules/sway.nix
    ../shared/nixos-modules/systemd-boot.nix
    ../shared/nixos-modules/yubikey.nix
    ../shared/nixos-modules/zfs.nix
    ./hardware-configuration.nix
    flakeInputs.home-manager.nixosModules.home-manager
  ];

  hardware.opengl.extraPackages =
    [ pkgs.vaapiIntel pkgs.libvdpau-va-gl pkgs.intel-media-driver ];
  hardware.enableRedistributableFirmware = true;
  environment.variables.VDPAU_DRIVER = lib.mkDefault "va_gl";

  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;
  boot.kernelParams = [
    # For Power consumption
    # https://kvark.github.io/linux/framework/2021/10/17/framework-nixos.html
    "mem_sleep_default=deep"
    # Workaround iGPU hangs
    # https://discourse.nixos.org/t/intel-12th-gen-igpu-freezes/21768/4
    "i915.enable_psr=1"
    # Without this sway won't find the GPU
    "i915.force_probe=4626"
    # My first attempt to hibernate resulted in weird screen flickering when I
    # came out of hibernation and then a failing 'zfs import trunk' after that,
    # which required 'zfs import -f -FX trunk' on a recovery system to repair.
    #
    # The link below suggests it might be fixed, but it wasn't on my system.
    # Maybe it requires a newer kernel version or ZFS? Let's not hibernate until
    # I figure it out.
    # https://github.com/NixOS/nixpkgs/pull/171680
    "nohibernate"
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
  powerManagement.powertop.enable = true;
  services.tlp.enable = true;
  services.logind.lidSwitch = "suspend";

  # Reset root filesystem at boot
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r trunk/root@blank
  '';

  environment.etc."NetworkManager/system-connections".source =
    "/persist/system-connections/";

  networking.hostId = "bbc4755f";

  networking.hostName = "sentient-tshirt";

  security.sudo.extraConfig = ''
    Defaults lecture=never
  '';

  environment.pathsToLink = [ "/share/fish" ]; # Needed for direnv integration.

  programs.command-not-found.enable = false;

  services.fwupd.enable = true;

  services.zrepl = {
    enable = true;
    settings = {
      jobs = [{
        type = "snap";
        name = "backup_persist";
        filesystems = {
          "trunk" = false;
          "trunk/persist" = true;
        };
        snapshotting = {
          type = "periodic";
          prefix = "zrepl_";
          interval = "10m";
        };
        pruning = {
          keep = [{
            type = "grid";
            regex = "zrepl_.*";
            grid = "1x1h(keep=all) | 24x1h | 6x1d | 4x7d | 120x30d";
          }];
        };
      }];
    };
  };

  users.mutableUsers = false;
  users.users.jasper = {
    isNormalUser = true;
    home = "/home/jasper";
    extraGroups = [ "wheel" "rslsync" "sway" ];
    hashedPassword =
      "$6$h6p1ovc5FdW$w8vrupUIOdgfgDJOxEfqPdibbitT3HfZkjVQDurQ7YHfxH6hyC1AUTMZ8qlGff5KCE4XQfYfR970S6BtTin3m.";
    uid = 1000;
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.jasper = (import ./home.nix);

  system.stateVersion = "22.05";
  system.autoUpgrade.enable = false;
}
