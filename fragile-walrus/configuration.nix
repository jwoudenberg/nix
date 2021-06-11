inputs:
{ pkgs, config, ... }:

{
  disabledModules = [ "services/networking/resilio.nix" ];
  imports = [
    ../shared/nixos-modules/resilio.nix
    ../shared/nixos-modules/system76-power.nix
    ./hardware-configuration.nix
  ];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.system76.enableAll = true;
  hardware.enableRedistributableFirmware = true;

  boot.kernelPackages =
    pkgs.linuxPackages_5_11; # Required by AMD 6700 graphics card
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 10;
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;
  boot.initrd.supportedFilesystems = [ "zfs" ];
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
    ln -sfn /persist/aws /home/jasper/.aws
  '';

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
  nixpkgs.overlays = builtins.attrValues inputs.self.overlays;

  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
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

  environment.systemPackages = [ pkgs.efibootmgr pkgs.system76-power ];

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
