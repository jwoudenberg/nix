final: prev:

let sources = import ../nix/sources.nix;
in { similar-sort = prev.callPackage sources.similar-sort { }; }
