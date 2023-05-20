{ config, pkgs, ... }:

# This is the configuration for my home router. Some useful resources I found
# to help me put this together:
# https://francis.begyn.be/blog/nixos-home-router
# https://francis.begyn.be/blog/ipv6-nixos-router
# https://www.jjpdev.com/posts/home-router-nixos/
# https://dataswamp.org/~solene/2022-08-03-nixos-with-live-usb-router.html
let

  bridge0Subnet = "10.38.38.1/24";
in {
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
  boot.loader.grub.version = 2;
  boot.loader.grub.device =
    "/dev/disk/by-id/ata-SSE064GMLCC-SBC-2S_C295072701DE00012853";

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = [ pkgs.neovim pkgs.flashrom ];

  # SSH
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
  };
  programs.mosh.enable = true;

  system.stateVersion = "22.11";

  # Networking
  networking.hostName = "airborne-cactus";

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # Define network topology using systemd-networkd. Used resources:
  # https://www.sherbers.de/diy-linux-router-part-2-interfaces-dhcp-and-vlan/
  systemd.network = {
    enable = true;
    wait-online.ignoredInterfaces = [ "tailscale0" ];

    links."10-wan" = {
      matchConfig = {
        MACAddress = "00:0d:b9:5f:c8:f9";
        Type = "ether";
      };
      linkConfig = { Name = "wan"; };
    };
    links."10-opt" = {
      matchConfig = {
        MACAddress = "00:0d:b9:5f:c8:f8";
        Type = "ether";
      };
      linkConfig = { Name = "opt"; };
    };
    links."10-lan1" = {
      matchConfig = {
        MACAddress = "00:0d:b9:5f:c8:fa";
        Type = "ether";
      };
      linkConfig = { Name = "lan1"; };
    };
    links."10-lan2" = {
      matchConfig = {
        MACAddress = "00:0d:b9:5f:c8:fb";
        Type = "ether";
      };
      linkConfig = { Name = "lan2"; };
    };
    links."10-wlan" = {
      matchConfig = {
        MACAddress = "04:f0:21:b2:61:c5";
        Type = "wlan";
      };
      linkConfig = { Name = "wlan"; };
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

    networks."10-wan" = {
      matchConfig = { Name = "wan"; };
      networkConfig = { LinkLocalAddressing = "no"; };
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
    networks."10-opt" = {
      matchConfig.Name = "opt";
      linkConfig.RequiredForOnline = "no";
      networkConfig = { LinkLocalAddressing = "no"; };
    };
    networks."10-lan1" = {
      matchConfig.Name = "lan1";
      linkConfig.RequiredForOnline = "no";
      networkConfig = {
        Bridge = "bridge0";
        LinkLocalAddressing = "no";
      };
    };
    networks."10-lan2" = {
      matchConfig.Name = "lan2";
      linkConfig.RequiredForOnline = "no";
      networkConfig = {
        Bridge = "bridge0";
        LinkLocalAddressing = "no";
      };
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

  # Some resources for upgrading to a 802.11ac endpoint at some point:
  # https://wiki.gentoo.org/wiki/Hostapd#802.11a.2Fn.2Fac_with_WPA2-PSK_and_CCMP
  # https://blog.fraggod.net/2017/04/27/wifi-hostapd-configuration-for-80211ac-networks.html
  # http://pisarenko.net/blog/2015/02/01/beginners-guide-to-802-dot-11ac-setup/
  # https://github.com/NixOS/nixpkgs/pull/222536
  services.hostapd = {
    enable = true;
    interface = "wlan";
    ssid = "Bergweg";
    countryCode = "NL";
    hwMode = "g";
    wpa = false; # Set in extraConfig below, to be able to use a password file.

    # The hostapd.wpa_psk file should contain lines with the following format:
    #    ma:ca:dd:re:ss:00 The Passphrase For Device A
    # The MAC address 00:00:00:00:00:00 works as a wildcard.
    # More info here: https://s3lph.me/automatically-rotating-guest-wifi-passwords-with-hostapd.html
    extraConfig = ''
      wpa=2
      wpa_key_mgmt=WPA-PSK
      wpa_psk_file=/persist/credentials/hostapd.wpa_psk
      bridge=bridge0
    '';
  };

  # PPPoE
  # https://helpdesk.freedom.nl/algemene-instellingen-eigen-modem
  # https://github.com/systemd/systemd/issues/481#issuecomment-543308915
}
