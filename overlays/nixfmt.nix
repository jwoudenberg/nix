self: super:

let
  src = super.fetchFromGitHub {
    owner = "serokell";
    repo = "nixfmt";
    rev = "af09262aa7d08d2b0905b11d2e8958889aadcf46";
    sha256 = "0njgjv6syv3sk97v8kq0cb4mhgrb7nag2shsj7rphs6h5b7k9nbx";
  };
in { nixfmt = import src { }; }
