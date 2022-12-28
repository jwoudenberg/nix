{ pkgs, ... }: {
  disabledModules = [ "services/networking/resilio.nix" ];
  imports = [ ./resilio.nix ];

  systemd.services.resilio.serviceConfig.LoadCredential = [
    "secret_for_jasper:/persist/credentials/resilio_jasper"
    "secret_for_hjgames:/persist/credentials/resilio_hjgames"
  ];

  systemd.services.resilio.serviceConfig.BindPaths =
    [ "/persist/hjgames:/run/hjgames" "/persist/jasper:/run/jasper" ];

  services.resilio = {
    enable = true;
    deviceName = "fragile-walrus";
    sharedFolders = [
      {
        directory = "/run/hjgames";
        secretFile = "$CREDENTIALS_DIRECTORY/secret_for_hjgames";
        useRelayServer = false;
        useTracker = true;
        useDHT = true;
        searchLAN = true;
        useSyncTrash = false;
        knownHosts = [ ];
      }
      {
        directory = "/run/jasper";
        secretFile = "$CREDENTIALS_DIRECTORY/secret_for_jasper";
        useRelayServer = false;
        useTracker = true;
        useDHT = true;
        searchLAN = true;
        useSyncTrash = false;
        knownHosts = [ ];
      }
    ];
  };

  fileSystems."/var/lib/resilio-sync" = {
    device = "/persist/resilio-sync";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
  };

  fileSystems."/home/jasper/docs" = {
    device = "/persist/jasper";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
  };

  fileSystems."/home/jasper/hjgames" = {
    device = "/persist/hjgames";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/persist" ];
  };
}
