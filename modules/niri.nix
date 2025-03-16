{ pkgs, ... }:
let
  wallpaper = ../wallpaper/wallpaper.png;
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
  hardware.graphics.enable = true;
  programs.niri.enable = true;
  fonts.packages = [ pkgs.fira-code ];

  services.greetd = {
    enable = true;
    vt = 2;
    settings = {
      # Automatically login. I already entered a password to unlock the disk.
      initial_session = {
        command = "niri-session";
        user = "jasper";
      };
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --greeting 'Hoi!' --cmd niri-session";
        user = "jasper";
      };
    };
  };
  # To avoid interleaving tuigreet output with booting output:
  # https://github.com/apognu/tuigreet/issues/17
  systemd.services.greetd.serviceConfig.Type = "idle";

  systemd.user.services.swaybg = {
    unitConfig = {
      PartOf = "graphical-session.target";
      After = "graphical-session.target";
      Requisite = "graphical-session.target";
    };
    serviceConfig = {
      ExecStart = "${pkgs.swaybg}/bin/swaybg -m fill -i '${wallpaper}'";
      Restart = "on-failure";
    };
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

  homedir.files.".config/niri/config.kdl" = pkgs.writeText "config" ''
    input {
        keyboard {
            xkb {
                options "ctrl:nocaps"
            }
        }

        touchpad {
            tap
        }

        focus-follows-mouse max-scroll-amount="0%"
    }

    layout {
        gaps 0

        focus-ring {
            off
        }

        border {
            width 1
            active-color "#ffc87f"
            inactive-color "#505050"
        }
    }

    hotkey-overlay {
        skip-at-startup
    }

    prefer-no-csd
    screenshot-path "~/screenshots/%Y-%m-%d %H-%M-%S.png"

    // Window rules let you adjust behavior for individual windows.
    // Find more information on the wiki:
    // https://github.com/YaLTeR/niri/wiki/Configuration:-Window-Rules

    binds {
        Mod+Slash { show-hotkey-overlay; }
        Mod+Return { spawn "${pkgs.kitty}/bin/kitty"; }
        Mod+P { spawn "kitty" "--single-instance" "--class=launcher" "--" "${pkgs.jwlaunch}/bin/launch"; }

        XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"; }
        XF86AudioMute        allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86AudioMicMute     allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
        XF86MonBrightnessDown { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "set" "5%-"; }
        XF86MonBrightnessUp { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "set" "5%+"; }
        XF86AudioPlay { spawn "${pkgs.playerctl}/bin/playerctl" "play-pause"; }
        XF86AudioNext { spawn "${pkgs.playerctl}/bin/playerctl" "next"; }
        XF86AudioPrev { spawn "${pkgs.playerctl}/bin/playerctl" "previous"; }
        XF86AudioMedia { spawn "${lock}/bin/lock"; }

        Mod+Q { close-window; }

        Mod+H     { focus-column-left; }
        Mod+J     { focus-window-down; }
        Mod+K     { focus-window-up; }
        Mod+L     { focus-column-right; }

        Mod+Shift+H     { move-column-left; }
        Mod+Shift+J     { move-window-down; }
        Mod+Shift+K     { move-window-up; }
        Mod+Shift+L     { move-column-right; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }
        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }
        Mod+Shift+5 { move-column-to-workspace 5; }
        Mod+Shift+6 { move-column-to-workspace 6; }
        Mod+Shift+7 { move-column-to-workspace 7; }
        Mod+Shift+8 { move-column-to-workspace 8; }
        Mod+Shift+9 { move-column-to-workspace 9; }

        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+C { center-column; }

        Print { screenshot; }
        Shift+Print { screenshot-window; }

        Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
    }
  '';
}
