#!/usr/bin/env fish
set root (dirname (status --current-filename))
cp $root/*.nix /etc/nixos
cp -r $root/pkgs /etc/nixos
