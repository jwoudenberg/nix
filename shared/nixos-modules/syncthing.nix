{ pkgs, ... }: {
  users.groups.syncdata.gid = 7;

  systemd.tmpfiles.rules =
    [ "d /persist/syncthing 0700 syncthing syncdata - -" ];

  systemd.services.syncthing.serviceConfig = {
    RuntimeDirectory = "syncthing";
    BindPaths = [
      "/run/syncthing:/persist"
      "/persist/jasper"
      "/persist/hjgames"
      "/persist/syncthing"
    ];
  };
  systemd.services.syncthing-init.serviceConfig = {
    BindPaths = [ "/run/syncthing-init:/persist" "/persist/syncthing" ];
  };
  services.syncthing = {
    enable = true;
    group = "syncdata";
    extraOptions = {
      options = {
        relaysEnabled = false;
        natEnabled = false;
        globalAnnounceEnabled = false;
        localAnnounceEnabled = false;
        urAccepted = -1;
      };
    };
    overrideFolders = true;
    overrideDevices = true;
    dataDir = "/persist";
    configDir = "/persist/syncthing";
    folders = {
      "jasper" = {
        path = "/persist/jasper";
        devices = [ "ai-banana" ];
      };
      "hjgames" = {
        path = "/persist/hjgames";
        devices = [ "ai-banana" ];
      };
    };
    devices = {
      "ai-banana" = {
        id = "4IBITW5-V77TJUE-A3DEGT2-C33VXJU-W2GTUE5-BZ3J7MJ-XYVS6PF-7JNVSAB";
        addresses = [ "tcp://ai-banana" ];
      };
    };
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