{ pkgs, lib, config, ... }: {
  xdg.mimeApps.defaultApplications = {
    "x-www-browser" = [ "qutebrowser.desktop" ];
    "x-scheme-handler/http" = [ "qutebrowser.desktop" ];
    "x-scheme-handler/https" = [ "qutebrowser.desktop" ];
  };

  programs.qutebrowser = {
    enable = true;
    aliases = {
      "q" = "tab-close";
      "reader" = "spawn --userscript readability";
    };
    keyBindings.normal = {
      "<Ctrl-O>" = "back";
      "<Ctrl-I>" = "forward";
      "gt" = "tab-next";
      "gT" = "tab-prev";
      "<Ctrl-K>" = "tab-next";
      "<Ctrl-J>" = "tab-prev";
      "<Ctrl-Shift-K>" = "tab-move +";
      "<Ctrl-Shift-J>" = "tab-move -";
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

      # Fingerprinting protection, see: https://coveryourtracks.eff.org
      # For sites that do require JS, I'm going to use Firefox because it has
      # better built-in fingerprinting protection and more users.
      content.javascript.enabled = false;
      # User-Agent lifted from Firefox with `privacy.resistFingerprinting`
      # enabled in about:config
      content.headers.user_agent =
        "Mozilla/5.0 (Windows NT 10.0; rv:113.0) Gecko/20100101 Firefox/113.0";
      content.headers.do_not_track = null;
      content.canvas_reading = false;
      content.webgl = false;
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
