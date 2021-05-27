# Temporary overlay to provide tabnine until the nixpkgs stable bundles it
# (looks like this will be in 21.05). This overlay is a lightly modified copy
# of the derivation currently present in nixpkgs-unstable:
# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/development/tools/tabnine/default.nix#L39

final: prev:

let
  version = "3.3.115";
  src = if prev.stdenv.hostPlatform.system == "x86_64-darwin" then
    prev.fetchurl {
      url =
        "https://update.tabnine.com/bundles/${version}/x86_64-apple-darwin/TabNine.zip";
      sha256 = "104h3b9cvmz2m27a94cfc00xm8wa2p1pvrfs92hrz59hcs8vdldf";
    }
  else if prev.stdenv.hostPlatform.system == "x86_64-linux" then
    prev.fetchurl {
      url =
        "https://update.tabnine.com/bundles/${version}/x86_64-unknown-linux-musl/TabNine.zip";
      sha256 = "0rs2vmdz8c9zs53pjbzy27ir0p5v752cpsnqfaqf0ilx7k6fpnnm";
    }
  else
    throw "Not supported on ${prev.stdenv.hostPlatform.system}";
in {
  tabnine = prev.stdenv.mkDerivation rec {
    pname = "tabnine";

    inherit version src;

    dontBuild = true;

    # Work around the "unpacker appears to have produced no directories"
    # case that happens when the archive doesn't have a subdirectory.
    setSourceRoot = "sourceRoot=`pwd`";

    nativeBuildInputs = [ prev.unzip ];

    installPhase = ''
      install -Dm755 -t $out/bin TabNine TabNine-deep-cloud TabNine-deep-local WD-TabNine
    '';

    meta = with prev.lib; {
      homepage = "https://tabnine.com";
      description =
        "Smart Compose for code that uses deep learning to help you write code faster";
      license = licenses.unfree;
      platforms = [ "x86_64-darwin" "x86_64-linux" ];
    };
  };
}
