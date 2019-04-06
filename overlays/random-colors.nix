self: super:

let
  src = super.fetchFromGitHub {
    owner = "jwoudenberg";
    repo = "random-colors";
    rev = "4fc8c71cffa91a34a7330d8f368e46fabed6b939";
    sha256 = "1diq954rshbp2mbjifhgifng993vbn3g7ndqc0nz653myzykc1mn";
  };
in
{
  random-colors = super.callPackage src {};
}
