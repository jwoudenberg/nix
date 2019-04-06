self: super:

let
src =
  super.fetchFromGitHub {
    owner = "target";
    repo = "lorri";
    rev = "a1e2a9c217432596be2036f4482d26a7c4ae85b6";
    sha256 = "0amhx366d5hgm9q0yfi0kg7sjyldpchnaj1ks59q8423xawy2kcl";
  };
in
{
  lorri = super.callPackage src { inherit src; };
}
