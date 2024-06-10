{ ... }:
{
  containers.gonic = {
    ephemeral = true;
    autoStart = true;
    enableTun = true;
    privateNetwork = true;
    bindMounts = {
      "/var/lib/private/gonic" = {
        hostPath = "/persist/gonic";
        isReadOnly = false;
      };
      "/persist/music" = {
        hostPath = "/persist/music";
        isReadOnly = true;
      };
      "/persist/music/00_playlists" = {
        hostPath = "/persist/music/00_playlists";
        isReadOnly = false;
      };
      "/persist/credentials" = {
        hostPath = "/persist/credentials";
        isReadOnly = true;
      };
    };
    config =
      { pkgs, ... }:
      {
        system.stateVersion = "24.05";
        services.gonic = {
          enable = true;
          settings = {
            music-path = [ "/persist/music" ];
            playlists-path = "/persist/music/00_playlists";
            listen-addr = "127.0.0.1:4553";
            proxy-prefix = "/music";
            # podcast-path is required by the nixos module, though I don't use it.
            podcast-path = "/var/lib/gonic/podcasts";
          };
        };

        systemd.services.tailscale-authenticate = {
          serviceConfig = {
            Type = "oneshot";
            EnvironmentFile = "/persist/credentials/freedom_imap_password";
            RuntimeDirectory = "tailscale-authenticate";
          };
          wantedBy = [ "tailscaled.service" ];
          script = ''
            set -eux

            GOMODCACHE="$RUNTIME_DIRECTORY/gomodcache"

            ${pkgs.go}/bin/go run tailscale.com/cmd/get-authkey@main \
              -tags tag:gonic \
              -preauth \
              > "/tailscale-authkey"
          '';
        };

        services.tailscale = {
          enable = true;
          authKeyFile = "/tailscale-authkey";
          extraUpFlags = [
            "--hostname"
            "gonic"
          ];
        };
      };
  };
}
