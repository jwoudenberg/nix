{
  pkgs,
  config,
  lib,
  flakeInputs,
  ...
}:

{
  imports = [
    ../modules/ergodox.nix
    ../modules/home.nix
    ../modules/installed-apps.nix
    ../modules/localization.nix
    ../modules/networking.nix
    ../modules/nix.nix
    ../modules/persist-linking.nix
    ../modules/pipewire.nix
    ../modules/ssh.nix
    ../modules/syncthing.nix
    ../modules/systemd-boot.nix
    ../modules/users.nix
    ../modules/zfs.nix
    ./hardware-configuration.nix
    ./specialisation-default.nix
  ];

  specialisation.gaming.configuration = import ./specialisation-gaming.nix { pkgs = pkgs; };

  specialisation.work.configuration = import ./specialisation-work.nix {
    pkgs = pkgs;
    lib = lib;
    config = config;
  };

  hardware.cpu.amd.updateMicrocode = true;
  hardware.system76.enableAll = true;
  hardware.enableRedistributableFirmware = true;
  hardware.i2c.enable = true;

  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;

  # Reset root filesystem at boot
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r trunk/encrypted/root@blank
  '';
  networking.hostId = "f1e5b37a";

  networking.hostName = "fragile-walrus";

  programs.command-not-found.enable = false;

  services.fwupd.enable = true;
  services.udisks2.enable = true;

  services.zrepl = {
    enable = true;
    settings = {
      jobs = [
        {
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
            keep = [
              {
                type = "grid";
                regex = "zrepl_.*";
                grid = "1x1h(keep=all) | 24x1h | 6x1d | 4x7d | 120x30d";
              }
            ];
          };
        }
      ];
    };
  };

  system.stateVersion = "24.05";
  system.autoUpgrade.enable = false;
}
