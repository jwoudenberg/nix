{ pkgs }:

pkgs.pass.override {
  xclip = pkgs.xclip;
  xdotool = pkgs.xdotool;
  dmenu = pkgs.dmenu;
  gnupg = (import ./gnupg.nix) { inherit pkgs; };
}
