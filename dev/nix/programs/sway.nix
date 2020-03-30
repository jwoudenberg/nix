{ pkgs, ... }: {
  home.file.".bash_profile".text = ''
    sway
  '';

  home.file.".config/sway/config".text = ''
    font pango:FiraCode 12
    floating_modifier Mod4
    default_border pixel 1
    default_floating_border normal 2
    hide_edge_borders both
    focus_wrapping no
    focus_follows_mouse yes
    focus_on_window_activation smart
    mouse_warping output
    workspace_layout default

    client.focused #4c7899 #285577 #ffffff #2e9ef4 #285577
    client.focused_inactive #333333 #5f676a #ffffff #484e50 #5f676a
    client.unfocused #333333 #222222 #888888 #292d2e #222222
    client.urgent #2f343a #900000 #ffffff #900000 #900000
    client.placeholder #000000 #0c0c0c #ffffff #000000 #0c0c0c
    client.background #ffffff

    bindsym Mod4+0 workspace 10
    bindsym Mod4+1 workspace 1
    bindsym Mod4+2 workspace 2
    bindsym Mod4+3 workspace 3
    bindsym Mod4+4 workspace 4
    bindsym Mod4+5 workspace 5
    bindsym Mod4+6 workspace 6
    bindsym Mod4+7 workspace 7
    bindsym Mod4+8 workspace 8
    bindsym Mod4+9 workspace 9
    bindsym Mod4+Down focus down
    bindsym Mod4+Left focus left
    bindsym Mod4+Return exec alacritty -e fish
    bindsym Mod4+Right focus right
    bindsym Mod4+Shift+0 move container to workspace 10
    bindsym Mod4+Shift+1 move container to workspace 1
    bindsym Mod4+Shift+2 move container to workspace 2
    bindsym Mod4+Shift+3 move container to workspace 3
    bindsym Mod4+Shift+4 move container to workspace 4
    bindsym Mod4+Shift+5 move container to workspace 5
    bindsym Mod4+Shift+6 move container to workspace 6
    bindsym Mod4+Shift+7 move container to workspace 7
    bindsym Mod4+Shift+8 move container to workspace 8
    bindsym Mod4+Shift+9 move container to workspace 9
    bindsym Mod4+Shift+Down move down
    bindsym Mod4+Shift+Left move left
    bindsym Mod4+Shift+Right move right
    bindsym Mod4+Shift+Up move up
    bindsym Mod4+Shift+h move left
    bindsym Mod4+Shift+j move down
    bindsym Mod4+Shift+k move up
    bindsym Mod4+Shift+l move right
    bindsym Mod4+Shift+q kill
    bindsym Mod4+Up focus up
    bindsym Mod4+f fullscreen toggle
    bindsym Mod4+h focus left
    bindsym Mod4+j focus down
    bindsym Mod4+k focus up
    bindsym Mod4+l focus right
    bindsym Mod4+p exec rofi -show run

    mode "resize" {
    bindsym Down resize grow height 10 px or 10 ppt
    bindsym Escape mode default
    bindsym Left resize shrink width 10 px or 10 ppt
    bindsym Return mode default
    bindsym Right resize grow width 10 px or 10 ppt
    bindsym Up resize shrink height 10 px or 10 ppt
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




    exec_always --no-startup-id /nix/store/d70qawzkq1v5k6s59idgh0h9mr7sqwma-feh-3.2.1/bin/feh --bg-fill $HOME/docs/wallpaper.png

    input type:keyboard {
      xkb_layout us
      xkb_variant ,nodeadkeys
      xkb_options ctrl:nocaps
    }
  '';
}
