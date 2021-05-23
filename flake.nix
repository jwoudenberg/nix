{
  description = "Jaspers Nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-20.09-darwin";
    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    home-manager.url = "github:nix-community/home-manager/release-20.09";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: {

    nixosConfigurations.timid-lasagna = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        (import ./timid-lasagna/configuration.nix inputs)
        modules/desktop-hardware.nix
        inputs.home-manager.nixosModules.home-manager
      ];
    };

    nixosConfigurations.ai-banana = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./ai-banana/configuration.nix ];
    };

    darwinConfigurations.sentient-tshirt = inputs.darwin.lib.darwinSystem {
      modules = [
        (import ./sentient-tshirt/configuration.nix inputs)
        inputs.home-manager.darwinModules.home-manager
      ];
    };

  };
}
