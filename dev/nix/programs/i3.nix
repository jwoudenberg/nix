{ pkgs, ... }: {

  xsession.enable = true;
  xsession.windowManager.i3.enable = true;

  xsession.windowManager.i3.config = rec {
    fonts = [ "FiraCode 12" ];

    window = {
      hideEdgeBorders = "both";
      border = 1;
      titlebar = false;
    };

    startup = [{
      command = "${pkgs.feh}/bin/feh --bg-fill $HOME/docs/wallpaper.png";
      always = true;
      notification = false;
    }];

    bars = [{
      position = "top";
      statusCommand = "i3status";
      mode = "hide";
      fonts = [ "FiraCode 12" ];
    }];

    modifier = "Mod4";

    floating.modifier = "Mod4";

    keybindings = {
      "${modifier}+Return" = "exec kitty -e fish";
      "${modifier}+Shift+q" = "kill";
      "${modifier}+p" = "exec rofi -show run";
      "${modifier}+h" = "focus left";
      "${modifier}+j" = "focus down";
      "${modifier}+k" = "focus up";
      "${modifier}+l" = "focus right";
      "${modifier}+Left" = "focus left";
      "${modifier}+Down" = "focus down";
      "${modifier}+Up" = "focus up";
      "${modifier}+Right" = "focus right";
      "${modifier}+Shift+h" = "move left";
      "${modifier}+Shift+j" = "move down";
      "${modifier}+Shift+k" = "move up";
      "${modifier}+Shift+l" = "move right";
      "${modifier}+Shift+Left" = "move left";
      "${modifier}+Shift+Down" = "move down";
      "${modifier}+Shift+Up" = "move up";
      "${modifier}+Shift+Right" = "move right";
      "${modifier}+f" = "fullscreen toggle";
      "${modifier}+1" = "workspace 1";
      "${modifier}+2" = "workspace 2";
      "${modifier}+3" = "workspace 3";
      "${modifier}+4" = "workspace 4";
      "${modifier}+5" = "workspace 5";
      "${modifier}+6" = "workspace 6";
      "${modifier}+7" = "workspace 7";
      "${modifier}+8" = "workspace 8";
      "${modifier}+9" = "workspace 9";
      "${modifier}+0" = "workspace 10";
      "${modifier}+Shift+1" = "move container to workspace 1";
      "${modifier}+Shift+2" = "move container to workspace 2";
      "${modifier}+Shift+3" = "move container to workspace 3";
      "${modifier}+Shift+4" = "move container to workspace 4";
      "${modifier}+Shift+5" = "move container to workspace 5";
      "${modifier}+Shift+6" = "move container to workspace 6";
      "${modifier}+Shift+7" = "move container to workspace 7";
      "${modifier}+Shift+8" = "move container to workspace 8";
      "${modifier}+Shift+9" = "move container to workspace 9";
      "${modifier}+Shift+0" = "move container to workspace 10";
    };
  };
}
