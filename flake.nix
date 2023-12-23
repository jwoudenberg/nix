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
    paulus.url = "github:jwoudenberg/paulus";
    paulus.inputs.nixpkgs.follows = "nixpkgs";
    todo-txt-web.url = "github:jwoudenberg/todo-txt-web";
    todo-txt-web.inputs.nixpkgs.follows = "nixpkgs";
    gonic.url = "github:sentriz/gonic/v0.16.2";
    gonic.flake = false;
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
          dedrm = prev.writeShellScriptBin "dedrm" ''
            set -euxo pipefail

            ACSM_FILE=$(realpath "$1")
            TEMP_DIR=$(mktemp --directory --tmpdir dedrm-XXXXXX)
            pushd "$TEMP_DIR"
            ADEPT_DIR="$TEMP_DIR/adept"

            ${pkgs.libgourou}/bin/adept_activate --anonymous --output-dir "$ADEPT_DIR"
            ${pkgs.libgourou}/bin/acsmdownloader "$ACSM_FILE" --adept-directory "$ADEPT_DIR" --output-file "drm_book.epub"
            ${pkgs.libgourou}/bin/adept_remove "drm_book.epub" --adept-directory "$ADEPT_DIR" --output-file "book.epub"
          '';
          jwlaunch = inputs.launch.defaultPackage."${system}";
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
          # Adapted from: https://github.com/NixOS/nixpkgs/blob/nixos-23.11/pkgs/servers/gonic/default.nix#L50
          # Updates gonic to 0.16.2. Once This version is available in Nixpkgs we can
          # remove this override.
          gonic = pkgs.buildGoModule rec {
            pname = "gonic";
            version = "0.16.2";
            src = inputs.gonic;

            nativeBuildInputs = [ pkgs.pkg-config ];
            buildInputs = [ pkgs.taglib pkgs.zlib ];
            vendorHash = "sha256-0M1vlTt/4OKjn9Ocub+9HpeRcXt6Wf8aGa/ZqCdHh5M=";
            doCheck = false;

            postPatch = ''
              substituteInPlace \
                transcode/transcode.go \
                --replace \
                  '`ffmpeg' \
                  '`${pkgs.lib.getBin pkgs.ffmpeg}/bin/ffmpeg'
            '' + ''
              substituteInPlace \
                jukebox/jukebox.go \
                --replace \
                  '"mpv"' \
                  '"${pkgs.lib.getBin pkgs.mpv}/bin/mpv"'
            '';
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
        buildInputs = [ pkgs.libgourou pkgs.luaformatter pkgs.lua53Packages.luacheck ];
      };

    };
}
