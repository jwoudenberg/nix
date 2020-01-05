self: super:

let
  src = super.fetchFromGitHub {
    owner = "jwoudenberg";
    repo = "random-colors";
    rev = "f1ad08f7699a613dd73575b7cc4df5eecff10edf";
    sha256 = "1rhcmn02l0j69b25qpnkqp3fn544a2phf3fpll1r4vx5q795ndi2";
  };
in { random-colors = super.callPackage src { }; }
