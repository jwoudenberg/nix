self: super:

let sources = import ../nix/sources.nix { };
in {
  jwlaunch = super.haskellPackages.callCabal2nix "launch" sources.launch { };
}
