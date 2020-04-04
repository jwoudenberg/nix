{ pkgs, ... }:

let release = "19.09";
in {
  imports = [
    ./modules/desktop-hardware.nix
    ./modules/mullvad-vpn.nix
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

  nixpkgs.config = import ./nixpkgs-config.nix;
  nix.nixPath = [
    "nixpkgs=http://nixos.org/channels/nixos-${release}/nixexprs.tar.xz"
    "home-manager=https://github.com/rycee/home-manager/archive/release-${release}.tar.gz"
    "nixos-config=/etc/nixos/configuration.nix"
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
  home-manager.users.jasper = (import ./home-linux.nix);

  system.stateVersion = release;
  system.autoUpgrade.enable = true;
}
