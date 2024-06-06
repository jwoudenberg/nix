{ ... }:
{
  containers.gonic = {
    ephemeral = true;
    autoStart = true;
    enableTun = true;
    privateNetwork = false;
    # forwardPorts = [
    #   {
    #     hostPort = 4553;
    #     containerPort = 4553;
    #     protocol = "tcp";
    #   }
    # ];
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
    };
    config =
      { ... }:
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
      };
  };
}
