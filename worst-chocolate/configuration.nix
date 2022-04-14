inputs:
{ config, pkgs, modulesPath, ... }: {
  # Nix
  system.stateVersion = "21.11";
  networking.hostName = "worst-chocolate";
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ inputs.self.overlays.linuxCustomPkgs ];

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 1d";
  };

  # Hardware
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };
  boot.cleanTmpDir = true;
  zramSwap.enable = true;

  # Packages
  environment.systemPackages = [ pkgs.tailscale ];

  # Tailscale
  services.tailscale.enable = true;

  # Mosh
  programs.mosh.enable = true;

  # SSH
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = let
    sshKeysSrc = builtins.fetchurl {
      url = "https://github.com/jwoudenberg.keys";
      sha256 = "sha256:1wfnzni5hw4q1jiki058l4qxxfzdbrp51d7l47bsq1wb20a7284i";
    };
  in builtins.filter (line: line != "")
  (pkgs.lib.splitString "\n" (builtins.readFile sshKeysSrc));

  # Network
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedTCPPorts = [
      config.services.resilio.listeningPort
      22 # ssh admin
      80 # webserver
    ];
    allowedUDPPorts = [
      config.services.resilio.listeningPort
      config.services.tailscale.port
      22 # ssh admin
      80 # webserver
    ];
  };

}
