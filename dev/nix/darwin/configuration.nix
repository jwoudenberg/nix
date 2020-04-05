{ config, pkgs, ... }:
let sources = import ../nix/sources.nix;
in {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [ ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/dev/nix/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.bash.enable = true;
  programs.fish.enable = true;
  # Hack to address an issue with Fish. We should be able to remove this once
  # fish has been upgraded to version 3.1.0 or later (looks like this will be in
  # the 20.09 nixpkgs release at the earliest). Addresses this problem:
  # https://github.com/LnL7/nix-darwin/issues/122
  #
  # How to verify removing this doesn't break anything: check the $PATH to see
  # the nix profile is loaded first. `which vim` should load a Nix-provided Vim,
  # not a MacOS provided one.
  programs.fish.shellInit = ''
    for p in /Users/jasper/.nix-profile/bin
      if not contains $p $fish_user_paths
        set -g fish_user_paths $p $fish_user_paths
      end
    end
  '';

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.maxJobs = 8;
  nix.buildCores = 8;
  nix.nixPath = [
    "darwin=${sources.darwin}"
    "home-manager=${sources.home-manager}"
    "nixpkgs=${sources.nixpkgs}"
  ];

  imports = [ <home-manager/nix-darwin> ];

  users.users.jasper = { home = "/Users/jasper"; };

  home-manager.users.jasper = import ./home.nix;

  nixpkgs = import ../config.nix;
}
