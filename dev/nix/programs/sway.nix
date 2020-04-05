{ pkgs, ... }:
let
  takeScreenshot = pkgs.writeShellScriptBin "take-screenshot" ''
    mkdir -p ~/tmp
    grim -g "$(slurp)" ~/tmp/screenshot_$(date --iso=seconds).png
  '';

  wallpaper = ../wallpaper/wallpaper.png;
in {
  home.file.".bash_profile".text = ''
    sway
  '';

  home.file.".config/sway/config".text = ''
    font pango:FiraCode 12
    floating_modifier Mod4
    default_border pixel 2
    default_floating_border normal 2
    hide_edge_borders none
    focus_wrapping no
    focus_follows_mouse yes
    focus_on_window_activation smart
    mouse_warping output
    workspace_layout default
    workspace 1

    client.focused #4c7899 #285577 #ffffff #2e9ef4 #285577
    client.focused_inactive #333333 #5f676a #ffffff #484e50 #5f676a
    client.unfocused #333333 #222222 #888888 #292d2e #222222
    client.urgent #2f343a #900000 #ffffff #900000 #900000
    client.placeholder #000000 #0c0c0c #ffffff #000000 #0c0c0c
    client.background #ffffff

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
      Mod4+Return exec alacritty -e fish
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
      Mod4+p exec wofi --show drun
      Mod4+s exec ${takeScreenshot}/bin/take-screenshot
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
      hidden_state hide
      position top
      status_command i3status
      workspace_buttons yes
      strip_workspace_numbers no
      tray_output primary

      colors {
        background #000000
        statusline #ffffff
        separator #666666
        focused_workspace #4c7899 #285577 #ffffff
        active_workspace #333333 #5f676a #ffffff
        inactive_workspace #333333 #222222 #888888
        urgent_workspace #2f343a #900000 #ffffff
        binding_mode #2f343a #900000 #ffffff
      }
    }

    output DVI-D-1 {
      background ${wallpaper} fill
    }

    input type:keyboard {
      xkb_layout us
      xkb_variant ,nodeadkeys
      xkb_options ctrl:nocaps
    }
  '';

  home.file.".config/swaylock/config".text = ''
    no-unlock-indicator
    image=${wallpaper}
    scaling=fill
  '';
}
