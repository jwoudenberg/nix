{ callPackage, fetchFromGitHub, buildGoPackage, stdenv }:
let
  version = "2.5.0";

  npmPkgs = callPackage ./frontend/default.nix { };

  rice = callPackage ../go.rice { };

  src = fetchFromGitHub {
    owner = "filebrowser";
    repo = "filebrowser";
    rev = "v${version}";
    sha256 = "0v2wxpp6v8is2asdknw5zsjrb64nm47r77b0z27rbypfbj812y29";
  };

  frontend = npmPkgs.package.override {
    name = "filebrowser-frontend-${version}";
    src = "${src}/frontend";
    version = version;
    postInstall = ''
      vue-cli-service build
      mkdir -p $out/frontend
      mv $out/lib/node_modules/filebrowser-frontend/dist $out/frontend/dist
      rm -r $out/lib
    '';
  };

in buildGoPackage {
  name = "filebrowser-${version}";
  version = version;
  goPackagePath = "github.com/filebrowser/filebrowser";
  src = src;
  goDeps = ./deps.nix;
  postPatch = ''
    cp -r ${frontend}/frontend/dist frontend/dist
    cd http
    ${rice}/bin/rice embed-go
  '';
  meta = with stdenv.lib; {
    description =
      "Web File Browser which can be used as a middleware or standalone app.";
    homepage = "https://filebrowser.org/";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
