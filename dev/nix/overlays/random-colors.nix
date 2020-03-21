self: super:

let
  src = super.fetchFromGitHub {
    owner = "jwoudenberg";
    repo = "random-colors";
    rev = "c53c6c31bb6868e5dc2ce3cc284d1064146aeece";
    sha256 = "0aq5pc7qslfm6fz30ziczrz8n0cj2qawcdrdwjv4vblwk634q7x7";
  };
in { random-colors = super.callPackage src { }; }
