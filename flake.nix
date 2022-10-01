{
  description = "Jaspers Nix configuration";

  inputs = {
    nixpkgs-nixos.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-22.05-darwin";
    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-nixos";
    book-alert.url = "github:jwoudenberg/book-alert";
    book-alert.inputs.nixpkgs.follows = "nixpkgs-nixos";
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
    todo-txt-web.url = "github:jwoudenberg/todo-txt-web";
    todo-txt-web.inputs.nixpkgs.follows = "nixpkgs-nixos";
    vale-Joblint.flake = false;
    vale-Joblint.url = "github:errata-ai/Joblint";
    vale-alex.flake = false;
    vale-alex.url = "github:errata-ai/alex";
    vale-proselint.flake = false;
    vale-proselint.url = "github:errata-ai/proselint";
    vale-write-good.flake = false;
    vale-write-good.url = "github:errata-ai/write-good";
    yarr.url = "github:nkanaev/yarr";
    yarr.flake = false;
  };

  outputs = inputs: {
    overlays = let
      mkOverlay = system: final: prev:
        let pkgs = inputs.nixpkgs-nixos.legacyPackages."${system}";
        in {
          book-alert = inputs.book-alert.defaultPackage."${system}";
          jwlaunch = inputs.launch.defaultPackage."${system}";
          keepassxc-pass-frontend =
            inputs.keepassxc-pass-frontend.defaultPackage."${system}";
          random-colors = inputs.random-colors.defaultPackage."${system}";
          rem2html = pkgs.writers.writePerlBin "rem2html" {
            libraries =
              [ pkgs.perlPackages.JSONMaybeXS pkgs.perlPackages.GetoptLong ];
          } (builtins.readFile "${inputs.rem2html}/rem2html/rem2html");
          similar-sort = inputs.similar-sort.defaultPackage."${system}";
          shy = inputs.shy.defaultPackage."${system}";
          paulus = inputs.paulus.defaultPackage."${system}";
          todo-txt-web = inputs.todo-txt-web.defaultPackage."${system}";
          valeStyles = pkgs.linkFarm "vale-styles" [
            {
              name = "alex";
              path = "${inputs.vale-alex}/alex";
            }
            {
              name = "Joblint";
              path = "${inputs.vale-Joblint}/Joblint";
            }
            {
              name = "proselint";
              path = "${inputs.vale-proselint}/proselint";
            }
            {
              name = "write-good";
              path = "${inputs.vale-write-good}/write-good";
            }
          ];
          yarr = pkgs.buildGoModule {
            name = "yarr";
            src = inputs.yarr;
            vendorSha256 = "yXnoibqa0+lHhX3I687thGgasaVeNiHpGFmtEnH7oWY=";
            subPackages = [ "src" ];
            tags = [ "sqlite_foreign_keys" "release" "linux" ];
            ldflags = [ "-s" "-w" ];
            postInstall = "mv $out/bin/src $out/bin/yarr";
          };
        };
    in {
      darwinCustomPkgs = mkOverlay "x86_64-darwin";
      linuxCustomPkgs = mkOverlay "x86_64-linux";
    };

    nixosConfigurations.fragile-walrus = inputs.nixpkgs-nixos.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ (import ./fragile-walrus/configuration.nix inputs) ];
    };

    nixosConfigurations.ai-banana = inputs.nixpkgs-nixos.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ (import ./ai-banana/configuration.nix inputs) ];
    };

    darwinConfigurations.sentient-tshirt = inputs.darwin.lib.darwinSystem {
      system = "x86_64-darwin";
      modules = [ (import ./sentient-tshirt/configuration.nix inputs) ];
    };

    homeConfigurations.jubilant-moss =
      inputs.home-manager.lib.homeManagerConfiguration {
        configuration = import ./jubilant-moss/home.nix inputs;
        system = "x86_64-linux";
        username = "jasper";
        homeDirectory = "/home/jasper";
        stateVersion = "22.05";
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
