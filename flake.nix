{
  description = "Jaspers Nix configuration";

  inputs = {
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-21.05-darwin";
    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    home-manager.url = "github:nix-community/home-manager/release-21.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    launch.url = "github:jwoudenberg/launch";
    launch.inputs.nixpkgs.follows = "nixpkgs";
    random-colors.url = "github:jwoudenberg/random-colors";
    random-colors.inputs.nixpkgs.follows = "nixpkgs";
    similar-sort.url =
      "git+https://git.bytes.zone/brian/similar-sort.git?ref=main";
    similar-sort.flake = false;
    nix-script.url = "github:BrianHicks/nix-script";
    nix-script.flake = false;
  };

  outputs = inputs: {

    overlays = let
      mkOverlay = system: final: prev: {
        jwlaunch = inputs.launch.defaultPackage."${system}";
        nix-script = final.callPackage inputs.nix-script { };
        random-colors = inputs.random-colors.defaultPackage."${system}";
        similar-sort = prev.callPackage inputs.similar-sort { };
        linuxPackages_5_12 = prev.linuxPackages_5_12.extend (_: _: {
          system76-power = final.callPackage
            "${inputs.nixpkgs-master}/pkgs/os-specific/linux/system76-power/default.nix"
            { };
        });
      };
    in {
      darwinCustomPkgs = mkOverlay "x86_64-darwin";
      linuxCustomPkgs = mkOverlay "x86_64-linux";
    };

    nixosConfigurations.fragile-walrus = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        (import ./fragile-walrus/configuration.nix inputs)
        inputs.home-manager.nixosModules.home-manager
      ];
    };

    nixosConfigurations.ai-banana = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ (import ./ai-banana/configuration.nix inputs) ];
    };

    darwinConfigurations.sentient-tshirt = inputs.darwin.lib.darwinSystem {
      inputs = inputs;

      modules = [
        (import ./sentient-tshirt/configuration.nix)
        inputs.home-manager.darwinModules.home-manager
      ];
    };

  };
}
