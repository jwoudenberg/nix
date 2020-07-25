{ buildGoPackage, stdenv }:

let
  ref = "d954009f7238df62c766980934c8ea7f161d0e59";

  src = builtins.fetchGit {
    url = "git@github.com:GeertJohan/go.rice";
    ref = ref;
  };

in buildGoPackage {
  name = "go.rice-${ref}";
  version = ref;
  goPackagePath = "github.com/GeertJohan/go.rice";
  src = src;
  goDeps = ./deps.nix;
  meta = with stdenv.lib; {
    description =
      "go.rice is a Go package that makes working with resources such as html,js,css,images,templates, etc very easy.";
    homepage = "https://github.com/GeertJohan/go.rice";
    license = licenses.bsd2;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
