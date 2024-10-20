{ pkgs, lib, ... }:
{
  xdg.mime.defaultApplications = {
    "x-www-browser" = [ "qutebrowser.desktop" ];
    "x-scheme-handler/http" = [ "qutebrowser.desktop" ];
    "x-scheme-handler/https" = [ "qutebrowser.desktop" ];
  };

  environment.systemPackages = [ pkgs.qutebrowser ];

  homedir.files = {
    ".config/qutebrowser/config.py" = pkgs.writeText "config.py" ''
      config.load_autoconfig(False)
      c.content.autoplay = False
      c.content.canvas_reading = False
      c.content.cookies.accept = "no-3rdparty"
      c.content.geolocation = False

      # User-Agent lifted from Firefox with `privacy.resistFingerprinting`
      # enabled in about:config
      c.content.headers.do_not_track = None
      c.content.headers.user_agent = "Mozilla/5.0 (Windows NT 10.0; rv:113.0) Gecko/20100101 Firefox/113.0"

      # Fingerprinting protection, see: https://coveryourtracks.eff.org
      # For sites that do require JS, I'm going to use Firefox because it has
      # better built-in fingerprinting protection and more users.
      c.content.javascript.enabled = False

      c.content.notifications.enabled = False
      c.content.pdfjs = True
      c.content.register_protocol_handler = False
      c.content.webgl = False
      c.downloads.location.prompt = False
      c.editor.command = ["kitty", "nvim", "{file}"]
      c.tabs.last_close = "close"
      c.url.start_pages = ["http://ai-banana"]
      c.aliases['q'] = "tab-close"
      c.aliases['reader'] = "spawn --userscript readability"
      config.bind("<Ctrl-I>", "forward", mode="normal")
      config.bind("<Ctrl-J>", "tab-prev", mode="normal")
      config.bind("<Ctrl-K>", "tab-next", mode="normal")
      config.bind("<Ctrl-O>", "back", mode="normal")
      config.bind("<Ctrl-Shift-J>", "tab-move -", mode="normal")
      config.bind("<Ctrl-Shift-K>", "tab-move +", mode="normal")
      config.bind("d", "nop", mode="normal")
      config.bind("gT", "tab-prev", mode="normal")
      config.bind("gt", "tab-next", mode="normal")

      # Enabling javascript for some sites. Far as I can tell there's no way to
      # express this using the `settings.*` values above, because we need to set
      # the same `content.javascript.enabled` key multiple times and also because
      # we need to pass an extra argument (the URL pattern).
      config.set('content.javascript.enabled', True, 'ai-banana.panther-trout.ts.net')
      config.set('content.javascript.enabled', True, '*.bandcamp.com')
      config.set('content.javascript.enabled', True, 'ftm.nl')
      config.set('content.javascript.enabled', True, 'github.com')
      config.set('content.javascript.enabled', True, 'hachyderm.io')
      config.set('content.javascript.enabled', True, 'kagi.com')
      config.set('content.javascript.enabled', True, 'roc.zulipchat.com')
      config.set('content.javascript.enabled', True, 'search.nixos.org')
      config.set('content.javascript.enabled', True, 'triodos.nl')
      config.set('content.javascript.enabled', True, 'ziglang.org')

      # Kagi session link obtained here: https://kagi.com/settings?p=user_details
      with open('/home/jasper/docs/.kagi-token', 'r') as f:
        kagi_token = f.read().strip()
      c.url.searchengines = {
          'DEFAULT':  f"https://kagi.com/search?token={kagi_token}&q={{}}"
      }
    '';
  };
}
