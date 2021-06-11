inputs: final: prev: {
  system76-power = final.rustPlatform.buildRustPackage rec {
    pname = "system76-power-${version}";
    version = "1.1.16";

    src = inputs.system76-power;
    nativeBuildInputs = [ final.pkg-config ];
    buildInputs = [ final.dbus final.libusb ];

    cargoSha256 = "sha256-YqGr6Qou73gBDgz+S4oNhPQfrv7rkys+xZkgMCQca1M=";

    postInstall = ''
      install -D -m -0644 data/system76-power.conf $out/etc/dbus-1/system.d/system76-power.conf
    '';

    meta = with final.lib; {
      description = "System76 Power Management";
      homepage = "https://github.com/pop-os/system76-power";
      license = licenses.gpl3;
      maintainers = [ ];
    };
  };
}
