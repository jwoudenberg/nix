{ fetchFromGitHub, buildGoPackage, stdenv }:

let
  ref = "d954009f7238df62c766980934c8ea7f161d0e59";

  src = fetchFromGitHub {
    owner = "GeertJohan";
    repo = "go.rice";
    rev = ref;
    sha256 = "19lca5hcw9milgmjv6vlcg8vq4mz9a9sp5bpihxvyza0da6pklmf";
  };

in buildGoPackage {
  name = "go.rice-${ref}";
  version = ref;
  goPackagePath = "github.com/GeertJohan/go.rice";
  src = src;
  goDeps = ./deps.nix;
  meta = with stdenv.lib; {
    description =
      "A Go package that makes working with resources such as html,js,css,images,templates, etc very easy.";
    homepage = "https://github.com/GeertJohan/go.rice";
    license = licenses.bsd2;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
