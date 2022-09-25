inputs:
{ modulesPath, pkgs, config, lib, ... }:

{
  disabledModules = [ "services/networking/resilio.nix" ];
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../shared/nixos-modules/resilio.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.enableRedistributableFirmware = true;
  hardware.keyboard.zsa.enable = true; # Support flashing Ergodox.

  boot.initrd.availableKernelModules =
    [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [ "console=tty1" "console=ttS0,115200" ];
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_5_15;
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;

  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };

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

  services.resolved.enable = true;

  networking.hostName = "jubilant-moss";
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;
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

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
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
