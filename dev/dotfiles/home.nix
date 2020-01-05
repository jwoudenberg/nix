if builtins.currentSystem == "x86_64-darwin" then
  import ./home-macos.nix
else
  import ./home-linux.nix
