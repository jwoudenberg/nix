self: super:

{
  comma = let sources = import ../nix/sources.nix;
  in self.callPackage sources.comma { };
}
