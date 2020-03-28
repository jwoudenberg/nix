self: super:

let
  src = super.fetchFromGitHub {
    owner = "jwoudenberg";
    repo = "random-colors";
    rev = "f6a74bc77042a33b3d14a4b56eabefcac024ff8e";
    sha256 = "0d7616xwr30alx8shdw834dmffbg3sky1rd3mb2nq809skif46vp";
  };
in { random-colors = super.callPackage src { }; }
