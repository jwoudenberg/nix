self: super:

{
  nix-script = let sources = import ../nix/sources.nix;
  in super.callPackage sources.nix-script { };
}
