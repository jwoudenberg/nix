{ pkgs, ... }:
let
  wallpaper = ../wallpaper/wallpaper.png;
  i3statusConfig = pkgs.writeTextFile {
    name = "i3status.conf";
    text = ''
      # see "man i3status" for documentation.
      general {
              colors = false
              interval = 5
      }

      order += "battery 1"
      order += "wireless wlp166s0"
      order += "tztime local"

      tztime local {
              format = "%Y-%m-%d %H:%M:%S"
      }

      battery 1 {
              format = "%percentage"
              format_down = ""
              path = "/sys/class/power_supply/BAT%d/uevent"
              low_threshold = 10
              format_percentage = "%.00f%s"
      }

      wireless wlp166s0 {
              format_up = "%essid"
              format_down = ""
      }
    '';
  };

  swaylockConfig = pkgs.writeTextFile {
    name = "swaylock.conf";
    text = ''
      no-unlock-indicator
      image=${wallpaper}
      scaling=fill
    '';
  };
  lock = pkgs.writeShellScriptBin "lock" ''
    ${pkgs.playerctl}/bin/playerctl pause
    exec ${pkgs.swaylock}/bin/swaylock \
      --config ${swaylockConfig} \
      --daemonize
  '';
in
{
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  programs.sway.enable = true;
  fonts.packages = [ pkgs.fira-code ];

  services.greetd = {
    enable = true;
    vt = 2;
    settings = {
      # Automatically login. I already entered a password to unlock the disk.
      initial_session = {
        command = "sway";
        user = "jasper";
      };
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --greeting 'Hoi!' --cmd sway";
        user = "jasper";
      };
    };
  };
  # To avoid interleaving tuigreet output with booting output:
  # https://github.com/apognu/tuigreet/issues/17
  systemd.services.greetd.serviceConfig.Type = "idle";

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };

  # Enable wayland for Chrome and Electron apps.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Add passwords store path for launcher
  environment.sessionVariables.PASSAGE_DIR = "/home/jasper/docs/password-store";

  # Some QT applications like puddletag do not start without this.
  environment.systemPackages = [
    pkgs.qt5.qtwayland
    lock
  ];

  homedir.files = {
    ".config/sway/config" = pkgs.writeText "config" ''
      font pango:FiraCode 12
      floating_modifier Mod4
      default_border pixel 2
      default_floating_border normal 2
      smart_borders on
      focus_wrapping no
      focus_follows_mouse yes
      focus_on_window_activation smart
      mouse_warping output
      workspace_layout default
      workspace 1
      primary_selection disabled

      set $clight #f6f5f5
      set $cdull #2f313d
      set $cbright #f1b630
      set $caccent #d26324
      set $cdark #2f313d

      client.focused $cbright $clight $cdark $caccent $cbright
      client.focused_inactive $cdull $clight $cdark $caccent $cdull
      client.unfocused $cdark $clight $cdark $caccent $cdark
      client.urgent $caccent $clight $cdark $caccent $caccent

      for_window [app_id="^launcher$"] floating enable, sticky enable, resize set 350 px 350 px, border pixel 3
      set $menu exec kitty --single-instance --class=launcher -- ${pkgs.jwlaunch}/bin/launch

      bindsym {
        Mod4+0 workspace 10
        Mod4+1 workspace 1
        Mod4+2 workspace 2
        Mod4+3 workspace 3
        Mod4+4 workspace 4
        Mod4+5 workspace 5
        Mod4+6 workspace 6
        Mod4+7 workspace 7
        Mod4+8 workspace 8
        Mod4+9 workspace 9
        Mod4+Down focus down
        Mod4+Left focus left
        Mod4+Return exec kitty --single-instance
        Mod4+Right focus right
        Mod4+Shift+0 move container to workspace 10
        Mod4+Shift+1 move container to workspace 1
        Mod4+Shift+2 move container to workspace 2
        Mod4+Shift+3 move container to workspace 3
        Mod4+Shift+4 move container to workspace 4
        Mod4+Shift+5 move container to workspace 5
        Mod4+Shift+6 move container to workspace 6
        Mod4+Shift+7 move container to workspace 7
        Mod4+Shift+8 move container to workspace 8
        Mod4+Shift+9 move container to workspace 9
        Mod4+Shift+Down move down
        Mod4+Shift+Left move left
        Mod4+Shift+Right move right
        Mod4+Shift+Up move up
        Mod4+Shift+h move left
        Mod4+Shift+j move down
        Mod4+Shift+k move up
        Mod4+Shift+l move right
        Mod4+Shift+q kill
        Mod4+Up focus up
        Mod4+f fullscreen toggle
        Mod4+h focus left
        Mod4+j focus down
        Mod4+k focus up
        Mod4+l focus right
        Mod4+p exec $menu

        XF86AudioRaiseVolume exec ${pkgs.pamixer}/bin/pamixer --unmute --increase 5
        XF86AudioLowerVolume exec ${pkgs.pamixer}/bin/pamixer --unmute --decrease 5
        XF86AudioMute exec ${pkgs.pamixer}/bin/pamixer --toggle-mute
        XF86MonBrightnessDown exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-
        XF86MonBrightnessUp exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%+
        XF86AudioPlay exec ${pkgs.playerctl}/bin/playerctl play-pause
        XF86AudioNext exec ${pkgs.playerctl}/bin/playerctl next
        XF86AudioPrev exec ${pkgs.playerctl}/bin/playerctl previous
        XF86AudioMedia exec ${lock}/bin/lock
      }

      mode "resize" bindsym {
        Down resize grow height 10 px or 10 ppt
        Escape mode default
        Left resize shrink width 10 px or 10 ppt
        Return mode default
        Right resize grow width 10 px or 10 ppt
        Up resize shrink height 10 px or 10 ppt
      }

      bar {
        font pango:FiraCode 12
        mode hide
        position top
        status_command "${pkgs.i3status}/bin/i3status -c ${i3statusConfig}"
        workspace_buttons yes
        strip_workspace_numbers no
        tray_output primary

        colors {
          background $cdark
          statusline $clight
          separator $cdark
          focused_workspace $cbright $cbright $cdark
          active_workspace $caccent $caccent $cdark
          inactive_workspace $cdark $cdark $clight
          urgent_workspace $cdull $cdull $cdark
        }
      }

      output * {
        background ${wallpaper} fill
      }

      input type:keyboard {
        xkb_layout us
        xkb_variant ,nodeadkeys
        xkb_options ctrl:nocaps,compose:prsc
      }

      input type:touchpad {
        tap enabled
      }

      exec "systemctl --user import-environment; systemctl --user start sway-session.target"
    '';
  };

  # This is needed for other wayland tools like wlsunset to trigger in the
  # right moment. Can be removed if I home-managerify the above configuration.
  # See: https://github.com/nix-community/home-manager/issues/1865
  systemd.user.targets.sway-session = {
    description = "sway compositor session";
    documentation = [ "man:systemd.special(7)" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };

  systemd.user.services.wlsunset = {
    description = "Day/night gamma adjustments for Wayland compositors.";
    partOf = [ "graphical-session.target" ];
    script = "${pkgs.wlsunset}/bin/wlsunset -l 52.4 -L 4.9 -t 4000";
  };
}
