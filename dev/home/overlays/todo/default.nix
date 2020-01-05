self: super:

let src = super.callPackage ./project.nix { }; in { todo = src.todo; }
