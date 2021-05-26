{ pkgs, ... }: {
  programs.direnv = {
    enable = true;
    enableNixDirenvIntegration = true;
    stdlib = ''
      use_flake() {
        watch_file flake.nix
        watch_file flake.lock
        eval "$(nix print-dev-env)"
      }
    '';
  };
}
