inputs:
{ pkgs, config, lib, ... }:

{
  disabledModules = [ "services/networking/resilio.nix" ];
  imports =
    [ ../shared/nixos-modules/resilio.nix ./hardware-configuration.nix ];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.system76.enableAll = true;
  hardware.enableRedistributableFirmware = true;
  hardware.keyboard.zsa.enable = true; # Support flashing Ergodox.

  boot.kernelPackages =
    pkgs.linuxPackages_5_14; # Required by AMD 6700 graphics card
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.systemd-boot.editor = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 10;
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r trunk/root@blank
  '';
  boot.supportedFilesystems = [ "zfs" ];

  system.activationScripts.persist = ''
    # Make /persist public so the rslsync user can look in it.
    chmod 755 /persist

    # Symbolic links to home directory.
    ln -sfn /persist/rslsync/books /home/jasper/books
    ln -sfn /persist/rslsync/jasper /home/jasper/docs
    ln -sfn /persist/rslsync/hjgames /home/jasper/hjgames
    ln -sfn /persist/dev /home/jasper/dev
    ln -sfn /persist/password-store /home/jasper/.password-store
    ln -sfn /persist/ssh /home/jasper/.ssh
    ln -sfn /persist/kube /home/jasper/.kube
    ln -sfn /persist/terraform.d /home/jasper/.terraform.d

    mkdir -p /home/jasper/.config
    chown jasper:users /home/jasper/.config
    ln -sfn /persist/random-colors /home/jasper/.config/random-colors

    # Tailscale state
    mkdir -p /var/lib/tailscale
    ln -sfn /persist/tailscale/files /var/lib/tailscale/files
    ln -sfn /persist/tailscale/tailscaled.state /var/lib/tailscale/tailscaled.state
    ln -sfn /persist/tailscale/tailscaled.log.conf /var/lib/tailscale/tailscaled.log.conf

    # Set permissions for rslsync dirs (these gets reset sometimes, don't know why)
    chown -R rslsync:rslsync /persist/rslsync
    chmod -R 770 /persist/rslsync
  '';

  environment.etc."NetworkManager/system-connections".source =
    "/persist/system-connections/";

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
    autoSnapshot.enable = true;
  };

  services.greetd = {
    enable = true;
    vt = 2;
    settings = {
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

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  networking.hostId = "f1e5b37a";
  networking.hostName = "fragile-walrus";
  networking.networkmanager = {
    enable = true;
    dns = "none";
  };
  networking.nameservers = [ "100.100.100.100" "1.1.1.1" ];
  networking.search = [ "jasperwoudenberg.com.beta.tailscale.net" ];
  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  console.keyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "Europe/Amsterdam";

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ inputs.self.overlays.linuxCustomPkgs ];

  nix.registry.nixpkgs.flake = inputs.nixpkgs-nixos;
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs-nixos}" ];
  nix.binaryCaches = [ "https://cache.nixos.org" "https://nri.cachix.org" ];
  nix.binaryCachePublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nri.cachix.org-1:9/BMj3Obc+uio3O5rYGT+egHzkBzDunAzlZZfhCGj6o="
  ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  security.sudo.extraConfig = ''
    Defaults lecture=never
  '';

  environment.systemPackages = [ pkgs.efibootmgr ];

  fonts.fonts = [ pkgs.fira-code ];

  programs.sway.enable = true;
  programs.xwayland.enable = false;
  programs.ssh.startAgent = true;
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

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };

  users.extraGroups.vboxusers.members = [ "jasper" ];

  users.mutableUsers = false;
  users.users.jasper = {
    isNormalUser = true;
    home = "/home/jasper";
    extraGroups = [ "wheel" "rslsync" "sway" "networkmanager" ];
    hashedPassword =
      "$6$h6p1ovc5FdW$w8vrupUIOdgfgDJOxEfqPdibbitT3HfZkjVQDurQ7YHfxH6hyC1AUTMZ8qlGff5KCE4XQfYfR970S6BtTin3m.";
    uid = 1000;
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.jasper = (import ./home.nix);

  system.stateVersion = "21.05";
  system.autoUpgrade.enable = false;

}
