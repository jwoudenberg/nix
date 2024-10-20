{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.whipper ];

  homedir.files.".config/whipper/whipper.conf" = pkgs.writeText "whipper.conf" ''
    [drive:ASUS%20%20%20%20%3ASDRW-08U9M-U%20%20%20%20%3AA112]
    vendor = ASUS
    model = SDRW-08U9M-U
    release = A112
    defeats_cache = False
    read_offset = 6

    [whipper.cd.rip]
    unknown = True
    track_template = %%A/%%d/%%t %%n
    disc_template = %%A/%%d/album
  '';
}
