{
  description = "Jaspers Nix configuration";

  inputs = {
    nixpkgs-nixos.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-21.11-darwin";
    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    home-manager.url = "github:nix-community/home-manager/release-21.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-nixos";
    comma.url = "github:nix-community/comma";
    # letting comma follow pinned nixpkgs currently doesn't work, because it
    # requires nix version at least 2.4, which isn't in release-21.11. Once
    # I switch to 22.05 I can comment out the line below.
    # comma.inputs.nixpkgs.follows = "nixpkgs-nixos";
    elm-pair.url = "github:jwoudenberg/elm-pair";
    elm-pair.inputs.nixpkgs.follows = "nixpkgs-nixos";
    launch.url = "github:jwoudenberg/launch";
    launch.inputs.nixpkgs.follows = "nixpkgs-nixos";
    random-colors.url = "github:jwoudenberg/random-colors";
    random-colors.inputs.nixpkgs.follows = "nixpkgs-nixos";
    rem2html.url =
      "git+https://git.skoll.ca/Skollsoft-Public/Remind.git?ref=master";
    rem2html.flake = false;
    similar-sort.url =
      "git+https://git.bytes.zone/brian/similar-sort.git?ref=main";
    shy.url = "github:jwoudenberg/shy";
    shy.inputs.nixpkgs.follows = "nixpkgs-nixos";
    keepassxc-pass-frontend.url = "github:jwoudenberg/keepassxc-pass-frontend";
    keepassxc-pass-frontend.inputs.nixpkgs.follows = "nixpkgs-nixos";
    paulus.url = "github:jwoudenberg/paulus";
    paulus.inputs.nixpkgs.follows = "nixpkgs-nixos";
  };

  outputs = inputs: {
    overlays = let
      mkOverlay = system: final: prev: {
        comma = inputs.comma.packages."${system}".comma;
        elm-pair-licensing-server =
          inputs.elm-pair.packages."${system}".licensing-server;
        jwlaunch = inputs.launch.defaultPackage."${system}";
        keepassxc-pass-frontend =
          inputs.keepassxc-pass-frontend.defaultPackage."${system}";
        random-colors = inputs.random-colors.defaultPackage."${system}";
        rem2html = let pkgs = inputs.nixpkgs-nixos.legacyPackages."${system}";
        in pkgs.writers.writePerlBin "rem2html" {
          libraries =
            [ pkgs.perlPackages.JSONMaybeXS pkgs.perlPackages.GetoptLong ];
        } (builtins.readFile "${inputs.rem2html}/rem2html/rem2html");
        similar-sort = inputs.similar-sort.defaultPackage."${system}";
        shy = inputs.shy.defaultPackage."${system}";
        paulus = inputs.paulus.defaultPackage."${system}";
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

    nixosConfigurations.worst-chocolate = inputs.nixpkgs-nixos.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ (import ./worst-chocolate/configuration.nix inputs) ];
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
