{
  description = "Jaspers Nix configuration";

  inputs = {
    nixpkgs-nixos.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    home-manager.url = "github:nix-community/home-manager/release-21.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-nixos";
    comma.url = "github:jwoudenberg/comma";
    comma.inputs.nixpkgs.follows = "nixpkgs-nixos";
    launch.url = "github:jwoudenberg/launch";
    launch.inputs.nixpkgs.follows = "nixpkgs-nixos";
    random-colors.url = "github:jwoudenberg/random-colors";
    random-colors.inputs.nixpkgs.follows = "nixpkgs-nixos";
    similar-sort.url =
      "git+https://git.bytes.zone/brian/similar-sort.git?ref=main";
    keepassxc-pass-frontend.url = "github:jwoudenberg/keepassxc-pass-frontend";
    keepassxc-pass-frontend.inputs.nixpkgs.follows = "nixpkgs-nixos";
  };

  outputs = inputs: {
    overlays = let
      mkOverlay = system: final: prev: {
        comma = inputs.comma.defaultPackage.${system};
        jwlaunch = inputs.launch.defaultPackage."${system}";
        keepassxc-pass-frontend =
          inputs.keepassxc-pass-frontend.defaultPackage."${system}";
        random-colors = inputs.random-colors.defaultPackage."${system}";
        similar-sort = inputs.similar-sort.defaultPackage."${system}";
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

    devShell = let
      mkDevShell = pkgs:
        pkgs.mkShell {
          buildInputs = [ pkgs.luaformatter pkgs.lua53Packages.luacheck ];
        };
    in {
      "x86_64-linux" =
        mkDevShell inputs.nixpkgs-nixos.legacyPackages."x86_64-linux";
      "x86_64-darwin" =
        mkDevShell inputs.nixpkgs-darwin.legacyPackages."x86_64-darwin";
    };

  };
}
