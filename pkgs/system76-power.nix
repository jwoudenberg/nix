{ pkg-config, libusb, dbus, lib, rustPlatform, fetchFromGitHub }:

let
  version = "1.1.16";
  sha256 = "sha256-OtrhvUkNNgg6KlrqjwiBKL4zuQZBWevb0xgtSlEW2rQ=";
in rustPlatform.buildRustPackage {
  pname = "system76-power-${version}";
  version = version;

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "system76-power";
    rev = version;
    sha256 = sha256;
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dbus libusb ];

  cargoSha256 = "sha256-YqGr6Qou73gBDgz+S4oNhPQfrv7rkys+xZkgMCQca1M=";

  postInstall = ''
    install -D -m -0644 data/system76-power.conf $out/etc/dbus-1/system.d/system76-power.conf
  '';

  meta = with lib; {
    description = "System76 Power Management";
    homepage = "https://github.com/pop-os/system76-power";
    license = licenses.gpl3;
    maintainers = [ ];
  };
}
