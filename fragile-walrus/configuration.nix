inputs:
{ pkgs, config, lib, ... }:

{
  disabledModules = [ "services/networking/resilio.nix" ];
  imports = [
    ../shared/nixos-modules/resilio.nix
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.system76.enableAll = true;
  hardware.enableRedistributableFirmware = true;
  hardware.keyboard.zsa.enable = true; # Support flashing Ergodox.
  hardware.i2c.enable = true;

  boot.kernelPackages =
    pkgs.linuxKernel.packages.linux_5_15; # Required by AMD 6700 graphics card
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.systemd-boot.editor = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 10;
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;

  # Reset root filesystem at boot
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r trunk/encrypted/root@blank
  '';

  systemd.services.persist-linking = {
    description = "Create symbolic links to /persist";
    after = [ "persist.mount" ];
    wantedBy = [ "multi-user.target" "tailscaled.service" "resilio.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -euxo pipefail

      # Make /persist public so the rslsync user can look in it.
      chmod 755 /persist

      # Symbolic links to home directory.
      ln -sfn /persist/rslsync/books /home/jasper/books
      ln -sfn /persist/rslsync/jasper /home/jasper/docs
      ln -sfn /persist/rslsync/hjgames /home/jasper/hjgames
      ln -sfn /persist/dev /home/jasper/dev

      mkdir -p /home/jasper/.config
      chown jasper:users /home/jasper/.config
      ln -sfn /persist/random-colors /home/jasper/.config/random-colors
      ln -sfn /persist/signal /home/jasper/.config/Signal
      ln -sfn /persist/keybase /home/jasper/.config/keybase
      ln -sfn /persist/pijul /home/jasper/.config/pijul

      mkdir -p /home/jasper/.cache
      chown jasper:users /home/jasper/.cache
      ln -sfn /persist/nix-index /home/jasper/.cache/nix-index

      mkdir -p /home/jasper/.config/TabNine
      chown jasper:users /home/jasper/.config/TabNine
      ln -sfn /persist/tabnine/tabnine_config.json /home/jasper/.config/TabNine/tabnine_config.json

      mkdir -p /home/jasper/.local/share/TabNine
      chown -R jasper:users /home/jasper/.local
      ln -sfn /persist/tabnine/models /home/jasper/.local/share/TabNine/models

      # Tailscale state
      mkdir -p /var/lib/tailscale
      ln -sfn /persist/tailscale/files /var/lib/tailscale/files
      ln -sfn /persist/tailscale/tailscaled.state /var/lib/tailscale/tailscaled.state
      ln -sfn /persist/tailscale/tailscaled.log.conf /var/lib/tailscale/tailscaled.log.conf

      # Set permissions for rslsync dirs (these gets reset sometimes, don't know why)
      chown -R rslsync:rslsync /persist/rslsync
      chmod -R 770 /persist/rslsync
    '';
  };

  environment.etc."NetworkManager/system-connections".source =
    "/persist/system-connections/";

  # Localization
  console.keyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
  };
  time.timeZone = "Europe/Amsterdam";

  # ZFS
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "f1e5b37a";
  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  services.greetd = {
    enable = true;
    vt = 2;
    settings = {
      # Automatically login. I already entered a password to unlock the disk.
      initial_session = {
        command = "sway";
        user = "jasper";
      };
      default_session = {
        command =
          "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --greeting 'Hoi!' --cmd sway";
        user = "jasper";
      };
    };
  };
  # To avoid interleaving tuigreet output with booting output:
  # https://github.com/apognu/tuigreet/issues/17
  systemd.services.greetd.serviceConfig.Type = "idle";

  # Use yubikey-agent for ssh access. Need to use a graphical pinentry option
  # here instead of curses, because pinentry is called by the yubikey-agent
  # daemon and so doesn't have a connection with the active terminal.
  services.yubikey-agent.enable = true;
  programs.gnupg.agent.pinentryFlavor = "qt";
  systemd.user.services.yubikey-agent.wantedBy =
    [ "graphical-session.target" ]; # Start automatically.

  services.keybase.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  networking.hostName = "fragile-walrus";
  networking.networkmanager = {
    enable = true;
    # dns = "none";
  };
  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ inputs.self.overlays.linuxCustomPkgs ];

  nix.registry.nixpkgs.flake = inputs.nixpkgs-nixos;
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs-nixos}" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  security.sudo.extraConfig = ''
    Defaults lecture=never
  '';

  environment.systemPackages = [ pkgs.efibootmgr pkgs.pinentry ];

  environment.pathsToLink = [ "/share/fish" ]; # Needed for direnv integration.

  fonts.fonts = [ pkgs.fira-code ];

  programs.sway.enable = true;
  programs.xwayland.enable = false;
  programs.command-not-found.enable = false;

  services.resilio = {
    enable = true;
    deviceName = "fragile-walrus";
    sharedFolders = let
      mkSharedFolder = name: {
        directory = "/persist/rslsync/" + name;
        secretFile = "/persist/rslsync/.secrets/" + name;
        useRelayServer = false;
        useTracker = true;
        useDHT = true;
        searchLAN = true;
        useSyncTrash = false;
        knownHosts = [ ];
      };
    in [
      (mkSharedFolder "books")
      (mkSharedFolder "hjgames")
      (mkSharedFolder "jasper")
    ];
  };

  services.tailscale.enable = true;
  services.pcscd.enable = true; # For Yubikey support
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

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };

  users.mutableUsers = false;
  users.users.jasper = {
    isNormalUser = true;
    home = "/home/jasper";
    extraGroups = [ "wheel" "rslsync" "sway" "networkmanager" "i2c" ];
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
