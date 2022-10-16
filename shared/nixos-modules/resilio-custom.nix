{ pkgs, ... }: {
  disabledModules = [ "services/networking/resilio.nix" ];
  imports = [ ./resilio.nix ];

  services.resilio = {
    enable = true;
    deviceName = "fragile-walrus";
    storagePath = "/persist/rslsync/state";
    sharedFolders = let
      mkSharedFolder = name: {
        directory = "/persist/rslsync/" + name;
        secretFile = "/persist/rslsync/.secrets/" + name;
        useRelayServer = false;
        useTracker = true;
        useDHT = true;
        searchLAN = true;
        useSyncTrash = false;
        knownHosts = [ ];
      };
    in [ (mkSharedFolder "hjgames") (mkSharedFolder "jasper") ];
  };

}
