final: prev:

{
  nix-script = let sources = import ../nix/sources.nix;
  in prev.callPackage sources.nix-script { };
}
