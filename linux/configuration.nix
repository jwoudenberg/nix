inputs:
{ pkgs, config, ... }:

{
  hardware.cpu.intel.updateMicrocode = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = [ pkgs.pkgsi686Linux.libva ];
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 10;
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;

  networking.hostName = "timid-lasagna";
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

  nixpkgs = import ../config.nix;

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

  environment.systemPackages = [ pkgs.efibootmgr pkgs.steam ];

  fonts.fonts = [ pkgs.fira-code ];

  programs.sway.enable = true;
  programs.ssh.startAgent = true;
  programs.command-not-found.enable = false;

  services.resilio2 = {
    enable = true;
    deviceName = "timid-lasagna";
    sharedFolders = let
      mkSharedFolder = name: {
        directory = "/home/rslsync/" + name;
        secretFile = "/home/rslsync/.secrets/" + name;
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

  users.users.jasper = {
    isNormalUser = true;
    home = "/home/jasper";
    extraGroups = [ "wheel" "rslsync" "sway" ];
    uid = 1000;
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.jasper = (import ./home.nix);

  system.stateVersion = "20.09";
  system.autoUpgrade.enable = false;

}
