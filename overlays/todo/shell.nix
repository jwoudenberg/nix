{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "todo-shell";
  buildInputs = with pkgs; [ haskellPackages.hindent stack stack2nix ];
}
