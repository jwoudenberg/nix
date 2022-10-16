{ pkgs, lib, config, ... }: {
  xdg.mimeApps.defaultApplications = {
    "x-www-browser" = [ "qutebrowser.desktop" ];
    "x-scheme-handler/http" = [ "qutebrowser.desktop" ];
    "x-scheme-handler/https" = [ "qutebrowser.desktop" ];
  };

  programs.qutebrowser = {
    enable = true;
    aliases = { "q" = "tab-close"; };
    keyBindings.normal = {
      "<Ctrl-O>" = "back";
      "<Ctrl-I>" = "forward";
      "gt" = "tab-next";
      "gT" = "tab-prev";
      "d" = "nop";
    };
    settings = {
      downloads.location.prompt = false;
      tabs.last_close = "close";
      content.cookies.accept = "no-3rdparty";
      content.autoplay = false;
      content.geolocation = false;
      content.pdfjs = true;
      content.notifications.enabled = false;
      content.register_protocol_handler = false;
      editor.command = [ "kitty" "nvim" "{file}" ];
      url.start_pages = [ "http://ai-banana" ];
    };
  };

  home.activation.writeStateFile = let
    initialStateFile = pkgs.writeTextFile {
      name = "state";
      text = ''
        [general]
        quickstart-done = 1
      '';
    };
  in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    QUTEBROWSER_STATE_PATH="${config.home.homeDirectory}/.local/share/qutebrowser/state"
    if [ ! -f "$QUTEBROWSER_STATE_PATH" ]; then
      $DRY_RUN_CMD mkdir -p $(dirname "$QUTEBROWSER_STATE_PATH")
      $DRY_RUN_CMD cat ${initialStateFile} > "$QUTEBROWSER_STATE_PATH"
    fi
  '';
}
