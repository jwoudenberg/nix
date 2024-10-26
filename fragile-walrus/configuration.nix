{
  pkgs,
  config,
  lib,
  flakeInputs,
  ...
}:

{
  imports = [
    ../modules/aerc.nix
    ../modules/age.nix
    ../modules/direnv.nix
    ../modules/ergodox.nix
    ../modules/fzf.nix
    ../modules/git.nix
    ../modules/home.nix
    ../modules/imv.nix
    ../modules/installed-apps.nix
    ../modules/jujutsu.nix
    ../modules/kitty.nix
    ../modules/localization.nix
    ../modules/neovim.nix
    ../modules/networking.nix
    ../modules/nix.nix
    ../modules/nushell.nix
    ../modules/persist-linking.nix
    ../modules/pipewire.nix
    ../modules/qrcode.nix
    ../modules/qutebrowser.nix
    ../modules/readline.nix
    ../modules/ripgrep.nix
    ../modules/screengrab.nix
    ../modules/ssh.nix
    ../modules/syncthing.nix
    ../modules/systemd-boot.nix
    ../modules/usb-scripts.nix
    ../modules/users.nix
    ../modules/vale.nix
    ../modules/whipper.nix
    ../modules/zathura.nix
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
