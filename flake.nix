{
  description = "Jaspers Nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    agenda-txt.url = "github:jwoudenberg/agenda.txt";
    agenda-txt.inputs.nixpkgs.follows = "nixpkgs";
    cooklang.url = "github:jwoudenberg/cooklang";
    cooklang.inputs.nixpkgs.follows = "nixpkgs";
    launch.url = "github:jwoudenberg/launch";
    launch.inputs.nixpkgs.follows = "nixpkgs";
    random-colors.url = "github:jwoudenberg/random-colors";
    random-colors.inputs.nixpkgs.follows = "nixpkgs";
    similar-sort.url =
      "git+https://git.bytes.zone/brian/similar-sort.git?ref=main";
    keepassxc-pass-frontend.url = "github:jwoudenberg/keepassxc-pass-frontend";
    keepassxc-pass-frontend.inputs.nixpkgs.follows = "nixpkgs";
    paulus.url = "github:jwoudenberg/paulus";
    paulus.inputs.nixpkgs.follows = "nixpkgs";
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
    vim-spell-nl.url = "http://ftp.vim.org/vim/runtime/spell/nl.utf-8.spl";
    vim-spell-nl.flake = false;
  };

  outputs = inputs:
    let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs {
        system = system;
        config.allowUnfree = true;
      };
    in
    {
      overlays = {
        linuxCustomPkgs = final: prev: {
          agenda-txt = inputs.agenda-txt.defaultPackage."${system}";
          cooklang = inputs.cooklang.defaultPackage."${system}";
          jwlaunch = inputs.launch.defaultPackage."${system}";
          keepassxc-pass-frontend =
            inputs.keepassxc-pass-frontend.defaultPackage."${system}";
          random-colors = inputs.random-colors.defaultPackage."${system}";
          similar-sort = inputs.similar-sort.defaultPackage."${system}";
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
          vim-spell-nl = "${inputs.vim-spell-nl}";
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

      nixosConfigurations.airborne-cactus = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { flakeInputs = inputs; };
        modules = [ (import ./airborne-cactus/configuration.nix) ];
      };

      homeConfigurations.jubilant-moss =
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs;
          modules = [ ./jubilant-moss/home.nix ];
          extraSpecialArgs.linuxCustomPkgs =
            inputs.self.overlays.linuxCustomPkgs;
        };

      devShell."x86_64-linux" = pkgs.mkShell {
        buildInputs = [ pkgs.luaformatter pkgs.lua53Packages.luacheck ];
      };

    };
}
