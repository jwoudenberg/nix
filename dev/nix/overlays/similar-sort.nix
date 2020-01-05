self: super:

{
  similar-sort = let
    brianDotfiles = super.fetchFromGitHub {
      owner = "BrianHicks";
      repo = "dotfiles.nix";
      rev = "df928289675cbeb6e72ddc08829604f174efcba6";
      sha256 = "1vrk56mp206hm4xrl01sgbihlzlyzgi7w291hzinqikmx4qrmp2i";
    };
    in super.callPackage (brianDotfiles + "/pkgs/similar-sort") { };
}
