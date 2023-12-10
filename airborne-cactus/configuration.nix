{ config, pkgs, ... }:

# This is the configuration for my home router. Some useful resources I found
# to help me put this together:
# https://francis.begyn.be/blog/nixos-home-router
# https://francis.begyn.be/blog/ipv6-nixos-router
# https://www.jjpdev.com/posts/home-router-nixos/
# https://dataswamp.org/~solene/2022-08-03-nixos-with-live-usb-router.html
let

  bridge0Subnet = "10.38.38.1/24";
in
{
  imports = [
    ./hardware-configuration.nix
    ../shared/nixos-modules/nix.nix
    ../shared/nixos-modules/users.nix
  ];

  # Allow serial-console connection using a program like minicom. Instrutions:
  # https://www.centennialsoftwaresolutions.com/post/configure-minicom-for-a-usb-to-serial-converter
  boot.kernelParams = [ "console=ttyS0,115200n8" ];
  boot.loader.grub.extraConfig = ''
    serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1
    terminal_input serial
    terminal_output serial
  '';

  boot.loader.grub.enable = true;
  boot.loader.grub.device =
    "/dev/disk/by-id/ata-SSE064GMLCC-SBC-2S_C295072701DE00012853";

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = [ pkgs.neovim pkgs.flashrom pkgs.iw ];

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  programs.mosh.enable = true;

  system.stateVersion = "23.11";

  # Networking
  networking.hostName = "airborne-cactus";
  networking.useNetworkd = true;

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # Define network topology using systemd-networkd. Used resources:
  # https://www.sherbers.de/diy-linux-router-part-2-interfaces-dhcp-and-vlan/
  systemd.network = {
    enable = true;
    wait-online.ignoredInterfaces = [ "tailscale0" ];

    links."10-opt" = {
      matchConfig = {
        MACAddress = "00:0d:b9:5f:c8:f8";
        Type = "ether";
      };
      linkConfig = { Name = "opt"; };
    };
    networks."10-opt" = {
      matchConfig.Name = "opt";
      linkConfig.RequiredForOnline = "no";
      networkConfig = { LinkLocalAddressing = "no"; };
    };

    links."10-lan0" = {
      matchConfig = {
        MACAddress = "00:0d:b9:5f:c8:f9";
        Type = "ether";
      };
      linkConfig = { Name = "lan0"; };
    };
    networks."10-lan0" = {
      matchConfig.Name = "lan0";
      networkConfig = {
        LinkLocalAddressing = "no";
        VLAN = "pppoe";
      };
    };

    links."10-lan1" = {
      matchConfig = {
        MACAddress = "00:0d:b9:5f:c8:fa";
        Type = "ether";
      };
      linkConfig = { Name = "lan1"; };
    };
    networks."10-lan1" = {
      matchConfig.Name = "lan1";
      linkConfig.RequiredForOnline = "no";
      networkConfig = {
        Bridge = "bridge0";
        LinkLocalAddressing = "no";
      };
    };

    links."10-lan2" = {
      matchConfig = {
        MACAddress = "00:0d:b9:5f:c8:fb";
        Type = "ether";
      };
      linkConfig = { Name = "lan2"; };
    };
    networks."10-lan2" = {
      matchConfig.Name = "lan2";
      linkConfig.RequiredForOnline = "no";
      networkConfig = {
        Bridge = "bridge0";
        LinkLocalAddressing = "no";
      };
    };

    links."10-wlan" = {
      matchConfig = {
        MACAddress = "04:f0:21:b2:61:c5";
        Type = "wlan";
      };
      linkConfig = { Name = "wlan"; };
    };
    networks."10-wlan" = {
      matchConfig.Name = "wlan";
      linkConfig.RequiredForOnline = "no";
      networkConfig = {
        # Not adding this interface to a bridge (yet), because hostapd has to
        # start first for it to work. Hostapd can then add it to the bridge
        # itself.
        # Bridge = "bridge0";
        LinkLocalAddressing = "no";
      };
    };

    # Note: netdevs don't currently auto-update when changed.
    # See: https://github.com/systemd/systemd/issues/9627
    netdevs."10-bridge0" = {
      netdevConfig = {
        MACAddress = "00:0d:b9:5f:c8:ff";
        Kind = "bridge";
        Name = "bridge0";
      };
    };
    networks."10-bridge0" = {
      matchConfig.Name = "bridge0";
      linkConfig.RequiredForOnline = "no";
      networkConfig = {
        Address = bridge0Subnet;
        DHCPServer = "yes";
        # Allow this bridge to be configured before lan or wlan connections to
        # it are made, to avoid blocking on boot.
        ConfigureWithoutCarrier = "yes";
      };
      dhcpServerConfig = {
        PoolOffset = 10;
        PoolSize = 100;
        EmitDNS = "yes";
        DNS = "9.9.9.9";
      };
    };

    # My internet provider (freedom.nl) requires me to connect through PPPoE,
    # with a vlan set. Details:
    # https://helpdesk.freedom.nl/algemene-instellingen-eigen-modem
    netdevs."10-pppoe" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "pppoe";
      };
      vlanConfig.Id = 6;
    };
    networks."10-pppoe" = {
      matchConfig.Name = "pppoe";
      linkConfig.ARP = "no";
      networkConfig = {
        LinkLocalAddressing = "no";
        IPv6AcceptRA = "no";
        DHCP = "no";
        LLMNR = "no";
      };
    };

    # The wan interface is created by pppd.
    networks."10-wan" = {
      matchConfig = { Name = "wan"; };
      networkConfig = {
        LinkLocalAddressing = "ipv6";
        DHCP = "no";
        IPv6AcceptRA = "yes";
        KeepConfiguration = "static";
        LLMNR = "no";
        LLDP = "no";
      };
      # Make this the default route, equivalent to setting:
      #   DefaultRouteOnDevice = "yes";
      # We don't use the above because we'd like to add a configuration
      # option for the route, performing MSS clamping.
      #
      # Using 'extraConfig' for this bit, because
      # 'TCPAdvertisedMaximumSegmentSize' is not known yet by the nixos module.
      extraConfig = ''
        [Route]
        Gateway=0.0.0.0
        TCPAdvertisedMaximumSegmentSize=1448
      '';
    };

  };

  # Resources for configuring nftables:
  # https://wiki.nftables.org/wiki-nftables/index.php/Simple_ruleset_for_a_home_router
  # http://ayekat.ch/blog/qemu-networkd-nftables
  # https://tailscale.com/kb/1096/nixos-minecraft/
  networking.firewall.enable = false;
  networking.nftables = {
    enable = true;
    ruleset = ''
      table inet global {

          chain inbound_wan {
            # accepting ping (icmp-echo-request) for diagnostic purposes.
            # However, it also lets probes discover this host is alive.
            icmp type echo-request limit rate 5/second accept
          }

          chain inbound_bridge0 {
              # accepting ping (icmp-echo-request) for diagnostic purposes.
              icmp type echo-request limit rate 5/second accept

              # allow DHCP, DNS and SSH
              ip protocol . th dport vmap { tcp . 22 : accept, udp . 53 : accept, tcp . 53 : accept, udp . 67 : accept }
          }

          chain inbound {
              type filter hook input priority 0; policy drop;

              # Allow traffic from established and related packets, drop invalid
              ct state vmap { established : accept, related : accept, invalid : drop }

              # allow loopback traffic, anything else jump to chain for further evaluation
              iifname vmap { lo : accept, wan : jump inbound_wan, bridge0 : jump inbound_bridge0, tailscale0: accept }

              # the rest is dropped by the above policy
          }

          chain forward {
              type filter hook forward priority 0; policy drop;

              #
              tcp flags syn tcp option maxseg size set rt mtu

              # Allow traffic from established and related packets, drop invalid
              ct state vmap { established : accept, related : accept, invalid : drop }

              # connections from the internal net to the internet or to other
              # internal nets are allowed
              iifname bridge0 accept

              # the rest is dropped by the above policy
          }

          chain postrouting {
              type nat hook postrouting priority 100; policy accept;

              # masquerade private IP addresses
              ip saddr ${bridge0Subnet} oifname wan masquerade
          }
      }
    '';
  };

  services.resolved.enable = true;
  services.tailscale.enable = true;

  services.hostapd = {
    enable = true;
    radios.wlan = {
      wifi4.enable = true;
      wifi4.capabilities = [
        # Available options here:
        # https://web.mit.edu/freebsd/head/contrib/wpa/hostapd/hostapd.conf
        # List below contains above options also present in `iw phy` output.
        "LDPC"
        "HT40-"
        "HT40+"
        "SHORT-GI-40"
        "TX-STBC"
        "RC-STBC1"
        "MAX_AMSDU-7935"
        "DSSS_CK-40"
      ];
      wifi5.enable = false;
      # wifi5.capabilities = [
      #   "MAX-MPDU-11545"
      #   "RXLDPC"
      #   "SHORT-GI-80"
      #   "TX-STBC-2BY1"
      #   "RX-STBC-1"
      # ];
      wifi6.enable = false;
      wifi7.enable = false;
      # Channels available in the Netherlands:
      # https://www.antagonist.nl/blog/wifi-verbeteren/
      #
      # Configuring wifi card for 5g:
      # https://superuser.com/questions/809282/wifi-5ghz-ap-mode-what-does-no-ir-means-and-can-i-bypass-it
      # https://medium.com/@renaudcerrato/how-to-build-your-own-wireless-router-from-scratch-part-3-d54eecce157f
      band = "2g";
      channel = 7;
      countryCode = "NL";
      networks.wlan = {
        ssid = "Bergweg";
        authentication = {
          mode = "wpa3-sae";
          saePasswordsFile = "/persist/credentials/hostapd.wpa_psk";
        };
      };
      settings.bridge = "bridge0";
    };
  };

  # PPPoE
  # https://helpdesk.freedom.nl/algemene-instellingen-eigen-modem
  # https://community.freedom.nl/t/voorbeeldconfiguratie-dualstack-router-met-systemd-networkd/2058
  # https://github.com/systemd/systemd/issues/481#issuecomment-543308915
  services.pppd = {
    enable = true;
    peers.freedom.config = ''
      ifname wan
      local
      noauth
      defaultroute
      +ipv6
      persist
      mru 1492
      mtu 1492
      plugin pppoe.so
      user fake@freedom.nl
      password 1234
      nic-pppoe
    '';
  };
}
