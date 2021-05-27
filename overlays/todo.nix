final: prev:

let src = prev.callPackage ../todo/default.nix { };
in { todo = src; }
