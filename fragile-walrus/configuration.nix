{ pkgs, config, lib, flakeInputs, ... }:

{
  imports = [
    ../shared/nixos-modules/ergodox.nix
    ../shared/nixos-modules/localization.nix
    ../shared/nixos-modules/networking.nix
    ../shared/nixos-modules/nix.nix
    ../shared/nixos-modules/pipewire.nix
    ../shared/nixos-modules/resilio-custom.nix
    ../shared/nixos-modules/sway.nix
    ../shared/nixos-modules/systemd-boot.nix
    ../shared/nixos-modules/yubikey.nix
    ../shared/nixos-modules/zfs.nix
    ./hardware-configuration.nix
    flakeInputs.home-manager.nixosModules.home-manager
  ];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.system76.enableAll = true;
  hardware.enableRedistributableFirmware = true;
  hardware.i2c.enable = true;

  boot.kernelPackages =
    pkgs.linuxKernel.packages.linux_5_15; # Required by AMD 6700 graphics card
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;

  # Reset root filesystem at boot
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r trunk/encrypted/root@blank
  '';
  networking.hostId = "f1e5b37a";

  services.keybase.enable = true;

  networking.hostName = "fragile-walrus";

  security.sudo.extraConfig = ''
    Defaults lecture=never
  '';

  environment.pathsToLink = [ "/share/fish" ]; # Needed for direnv integration.

  programs.command-not-found.enable = false;

  services.fwupd.enable = true;

  # zrepl
  services.zrepl = {
    enable = true;
    settings = {
      jobs = [{
        type = "push";
        name = "backup_persist";
        filesystems = {
          "trunk" = false;
          "trunk/encrypted/persist" = true;
        };
        connect = {
          type = "tcp";
          address = "ai-banana:8087";
        };
        snapshotting = {
          type = "periodic";
          prefix = "zrepl_";
          interval = "10m";
        };
        send = { encrypted = true; };
        pruning = {
          # Keep all snapshots locally. Pruning of local snapshots is performed
          # by the services.zfs.autoSnapshot configuration.
          keep_sender = [{
            type = "grid";
            regex = "zrepl_.*";
            grid = "1x1h(keep=all) | 24x1h | 6x1d | 4x7d | 120x30d";
          }];
          keep_receiver = [{
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
    extraGroups = [ "wheel" "rslsync" "sway" "i2c" ];
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
