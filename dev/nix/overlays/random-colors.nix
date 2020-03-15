self: super:

let
  src = super.fetchFromGitHub {
    owner = "jwoudenberg";
    repo = "random-colors";
    rev = "a32eb5f030749012994045bd85dd354cd28c2fd0";
    sha256 = "0qak191nw5bicks3xp54vyfnx5is3g7i8vnwda36nffa8qa34r21";
  };
in { random-colors = super.callPackage src { }; }
