{ pkgs, ... }:

let
  calibre = pkgs.calibre.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ pkgs.makeWrapper ];
    postInstall = ''
      wrapProgram $out/bin/calibre --add-flags '--with-library=/persist/rslsync/books'
    '';
  });
in {

  home.packages = [ calibre ];
}
