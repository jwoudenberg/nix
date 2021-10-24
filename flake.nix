{
  description = "Jaspers Nix configuration";

  inputs = {
    nixpkgs-nixos.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-21.05-darwin";
    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    home-manager.url = "github:nix-community/home-manager/release-21.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-nixos";
    launch.url = "github:jwoudenberg/launch";
    launch.inputs.nixpkgs.follows = "nixpkgs-nixos";
    random-colors.url = "github:jwoudenberg/random-colors";
    random-colors.inputs.nixpkgs.follows = "nixpkgs-nixos";
    similar-sort.url =
      "git+https://git.bytes.zone/brian/similar-sort.git?ref=main";
    similar-sort.inputs.nixpks.follows = "nixpkgs-nixos";
  };

  outputs = inputs: {

    overlays = let
      mkOverlay = system: final: prev: {
        jwlaunch = inputs.launch.defaultPackage."${system}";
        random-colors = inputs.random-colors.defaultPackage."${system}";
        similar-sort = inputs.similar-sort.defaultPackage."${system}";
        linuxPackages_5_14 = prev.linuxPackages_5_14.extend (_: _: {
          # I need a newer kernel than what's available in 21.05 to support my
          # graphics card. ZFS support for these newer kernels is still a work
          # in progress, so that means I need to move to the unstable branch for
          # ZFS support too. I should be able to move back to defaults come the
          # 21.11 release.
          zfs = final.linuxPackages_5_14.zfsUnstable;
        });
      };
    in {
      darwinCustomPkgs = mkOverlay "x86_64-darwin";
      linuxCustomPkgs = mkOverlay "x86_64-linux";
    };

    nixosConfigurations.fragile-walrus = inputs.nixpkgs-nixos.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        (import ./fragile-walrus/configuration.nix inputs)
        inputs.home-manager.nixosModules.home-manager
      ];
    };

    nixosConfigurations.ai-banana = inputs.nixpkgs-nixos.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ (import ./ai-banana/configuration.nix inputs) ];
    };

    darwinConfigurations.sentient-tshirt = inputs.darwin.lib.darwinSystem {
      system = "x86_64-darwin";
      inputs = inputs;

      modules = [
        (import ./sentient-tshirt/configuration.nix)
        inputs.home-manager.darwinModules.home-manager
      ];
    };

  };
}
