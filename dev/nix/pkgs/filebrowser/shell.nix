{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell { buildInputs = [ pkgs.nodePackages.node2nix pkgs.vgo2nix ]; }
