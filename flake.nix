{
  description = "Jaspers Nix configuration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";

  outputs = { self, nixpkgs }: {

    nixosConfigurations.jasper-desktop-nixos = nixpkgs.lib.nixosSystem {
      modules = [ linux/configuration.nix ];
      system = "x86_64-linux";
    };

  };
}
