{
  description = "Jaspers Nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    book-alert.url = "github:jwoudenberg/book-alert";
    book-alert.inputs.nixpkgs.follows = "nixpkgs";
    launch.url = "github:jwoudenberg/launch/v2";
    launch.inputs.nixpkgs.follows = "nixpkgs";
    random-colors.url = "github:jwoudenberg/random-colors";
    random-colors.inputs.nixpkgs.follows = "nixpkgs";
    rem2html.url =
      "git+https://git.skoll.ca/Skollsoft-Public/Remind.git?ref=master";
    rem2html.flake = false;
    similar-sort.url =
      "git+https://git.bytes.zone/brian/similar-sort.git?ref=main";
    shy.url = "github:jwoudenberg/shy";
    shy.inputs.nixpkgs.follows = "nixpkgs";
    keepassxc-pass-frontend.url = "github:jwoudenberg/keepassxc-pass-frontend";
    keepassxc-pass-frontend.inputs.nixpkgs.follows = "nixpkgs";
    paulus.url = "github:jwoudenberg/paulus";
    paulus.inputs.nixpkgs.follows = "nixpkgs";
    smtprelay.url = "github:decke/smtprelay";
    smtprelay.flake = false;
    todo-txt-web.url = "github:jwoudenberg/todo-txt-web";
    todo-txt-web.inputs.nixpkgs.follows = "nixpkgs";
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
    overlays = {
      linuxCustomPkgs = final: prev:
        let
          system = "x86_64-linux";
          pkgs = inputs.nixpkgs.legacyPackages."${system}";
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
          smtprelay = pkgs.buildGo118Module {
            name = "smtprelay";
            src = inputs.smtprelay;
            vendorSha256 =
              "sha256-mit4wM4WQJiGaKzEW5ZSaZoe/bRMtq16f5JPk6mRq1k=";
          };
          yarr = pkgs.buildGoModule {
            name = "yarr";
            src = inputs.yarr;
            vendorSha256 = null;
            subPackages = [ "src" ];
            tags = [ "sqlite_foreign_keys" "release" "linux" ];
            ldflags = [ "-s" "-w" ];
            postInstall = "mv $out/bin/src $out/bin/yarr";
          };
        };
    };

    nixosConfigurations.fragile-walrus = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { flakeInputs = inputs; };
      modules = [ (import ./fragile-walrus/configuration.nix) ];
    };

    nixosConfigurations.sentient-tshirt = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { flakeInputs = inputs; };
      modules = [ (import ./sentient-tshirt/configuration.nix) ];
    };

    nixosConfigurations.ai-banana = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { flakeInputs = inputs; };
      modules = [ (import ./ai-banana/configuration.nix) ];
    };

    homeConfigurations.jubilant-moss =
      inputs.home-manager.lib.homeManagerConfiguration {
        configuration = import ./jubilant-moss/home.nix inputs;
        system = "x86_64-linux";
        username = "jasper";
        homeDirectory = "/home/jasper";
        stateVersion = "22.05";
      };

    devShell."x86_64-linux" =
      let pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
      in pkgs.mkShell {
        buildInputs = [ pkgs.luaformatter pkgs.lua53Packages.luacheck ];
      };

  };
}
