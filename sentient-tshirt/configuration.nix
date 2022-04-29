inputs:
{ config, pkgs, ... }:

{
  imports = [
    ../shared/darwin-modules/yubikey-agent.nix
    inputs.home-manager.darwinModules.home-manager
  ];

  # List packages installed in system profile.
  environment.systemPackages = [ ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  services.yubikey-agent.enable = true;

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
  nix.package = pkgs.nix_2_4;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nix.gc = {
    automatic = true;
    interval = { Weekday = 7; }; # Every sunday
    options = "--delete-older-than 7d";
    user = "root";
  };

  users.users.jasper = { home = "/Users/jasper"; };
  users.nix.configureBuildUsers = true;

  home-manager.useGlobalPkgs = true;
  home-manager.users.jasper = import ./home.nix;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ inputs.self.overlays.darwinCustomPkgs ];

  system.defaults.NSGlobalDomain.AppleKeyboardUIMode = 3;
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;
  system.defaults.dock.show-recents = false;

  system.defaults.trackpad.Clicking = true;

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  networking.hostName = "sentient-tshirt";
}
