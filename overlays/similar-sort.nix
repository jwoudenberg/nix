self: super:

let sources = import ../nix/sources.nix;
in { similar-sort = self.callPackage sources.similar-sort { }; }
