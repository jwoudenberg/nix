{
  description = "Jaspers Nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
    home-manager.url = "github:nix-community/home-manager/release-20.09";
  };

  outputs = { nixpkgs, home-manager, ... }: {

    nixosConfigurations.jasper-desktop-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        linux/configuration.nix
        modules/desktop-hardware.nix
        home-manager.nixosModules.home-manager
      ];
    };

  };
}
