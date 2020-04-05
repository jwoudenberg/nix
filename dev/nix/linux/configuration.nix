{ pkgs, ... }:

let sources = import ../nix/sources.nix;
in {
  imports = [
    ../modules/desktop-hardware.nix
    ../modules/mullvad-vpn.nix
    <home-manager/nixos>
  ];

  hardware.cpu.intel.updateMicrocode = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = [ pkgs.pkgsi686Linux.libva ];
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 10;

  networking.hostName = "jasper-desktop-nixos";
  networking.networkmanager.enable = true;

  i18n = {
    consoleFont = "FiraCode 16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/London";

  nixpkgs = import ../config.nix;

  nix.nixPath = [
    "nixpkgs=${sources.nixpkgs}"
    "home-manager=${sources.home-manager}"
    "nixos-config=/etc/nixos/linux/configuration.nix"
  ];

  environment.systemPackages = with pkgs; [
    docker
    efibootmgr
    mullvad-vpn
    steam
  ];

  fonts.fonts = [ pkgs.fira-code ];

  programs.sway.enable = true;

  services.resilio.enable = true;
  services.resilio.deviceName = "jasper-desktop-nixos";
  services.resilio.enableWebUI = true;
  services.resilio.httpListenPort = 8888;

  services.pcscd.enable = true; # For Yubikey support
  virtualisation.docker.enable = true;
  services.mullvad-vpn.enable = true;

  users.users.jasper = {
    isNormalUser = true;
    home = "/home/jasper";
    extraGroups = [ "wheel" "rslsync" "docker" "sway" ];
    uid = 1000;
  };

  home-manager.useUserPackages = true;
  home-manager.users.jasper = (import ./home.nix);

  system.stateVersion = "19.09";
  system.autoUpgrade.enable = true;
}
