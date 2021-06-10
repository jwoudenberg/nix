{ pkgs, ... }: {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland.override {
      extraPrefs = ''
        pref("browser.download.dir", "~/downloads");
        pref("browser.download.useDownloadDir", true);
        pref("browser.link.open_newwindow", 0);
        pref("browser.newtabpage.enabled", false);
        pref("browser.startup.homepage", "about:blank");
        pref("browser.tabs.allowTabDetach", false);
        pref("browser.urlbar.suggest.bookmark", false);
        pref("browser.urlbar.suggest.engines", false);
        pref("browser.urlbar.suggest.history", false);
        pref("browser.urlbar.suggest.quicksuggest", false);
        pref("browser.urlbar.suggest.searches", false);
        pref("browser.urlbar.suggest.topsites", false);
        pref("browser.warnOnQuit", false);
        pref("extensions.pocket.enabled", false);
        pref("identity.fxaccounts.enabled", false);
        pref("network.cookie.cookieBehavior", 1);
        pref("signon.rememberSignons", false);
      '';
      extraPolicies = {
        SearchEngines = { Default = "DuckDuckGo"; };
        ShowHomeButton = false;
      };
    };
  };
}
