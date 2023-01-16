{ pkgs, config, lib, flakeInputs, ... }:

{
  imports = [
    ../shared/nixos-modules/ergodox.nix
    ../shared/nixos-modules/localization.nix
    ../shared/nixos-modules/networking.nix
    ../shared/nixos-modules/nix.nix
    ../shared/nixos-modules/persist-linking.nix
    ../shared/nixos-modules/pipewire.nix
    ../shared/nixos-modules/syncthing.nix
    ../shared/nixos-modules/systemd-boot.nix
    ../shared/nixos-modules/users.nix
    ../shared/nixos-modules/yubikey.nix
    ../shared/nixos-modules/zfs.nix
    ./hardware-configuration.nix
    ./specialisation-default.nix
    flakeInputs.home-manager.nixosModules.home-manager
  ];

  specialisation.gaming.configuration =
    import ./specialisation-gaming.nix { pkgs = pkgs; };

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

  environment.pathsToLink = [ "/share/fish" ]; # Needed for direnv integration.

  programs.command-not-found.enable = false;

  services.fwupd.enable = true;
  services.udisks2.enable = true;

  services.zrepl = {
    enable = true;
    settings = {
      jobs = [{
        type = "snap";
        name = "backup_persist";
        filesystems = {
          "trunk" = false;
          "trunk/encrypted/persist" = true;
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

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.jasper = (import ./home.nix);

  system.stateVersion = "22.11";
  system.autoUpgrade.enable = false;
}
