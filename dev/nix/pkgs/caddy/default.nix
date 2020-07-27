{ buildGoModule, fetchFromGitHub, stdenv }:

# Fork of the Caddy package to add plugin support:
# https://github.com/NixOS/nixpkgs/blob/nixos-20.03/pkgs/servers/caddy/default.nix
#
# Blatently copied from ooesili:
# https://github.com/NixOS/nixpkgs/issues/14671#issuecomment-588038463

buildGoModule rec {
  pname = "caddy";
  version = "1.0.5";

  goPackagePath = "github.com/caddyserver/caddy";

  subPackages = [ "caddy" ];

  src = fetchFromGitHub {
    owner = "caddyserver";
    repo = pname;
    rev = "v${version}";
    sha256 = "0jrhwmr6gggppskg5h450wybzkv17iq69dgw36hd1dp56q002i7g";
  };
  modSha256 = "1m0lzwz5k79z1y0jqdkk721j8bdjjhli6lv1dy1h4r5f18yjn69q";

  overrideModAttrs = (old: {
    preBuild = ''
      go mod edit -require=github.com/tarent/loginsrv@v1.3.1
      go mod edit -require=github.com/BTBurke/caddy-jwt@v3.7.1+incompatible
    '';
  });

  preBuild = ''
    cat << EOF > caddy/main.go
    package main

    import (
      "github.com/caddyserver/caddy/caddy/caddymain"

      _ "github.com/BTBurke/caddy-jwt"
      _ "github.com/tarent/loginsrv/caddy"
    )

    func main() {
      caddymain.EnableTelemetry = false
      caddymain.Run()
    }
    EOF
  '';
}
