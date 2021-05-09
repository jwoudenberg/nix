{ pkgs, ... }: {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland;
    profiles.jasper = {
      id = 0;
      isDefault = true;
      settings = {
        "browser.startup.homepage" = "about:blank";
        "browser.urlbar.suggest.searches" = false;
        "browser.urlbar.suggest.history" = false;
        "network.cookie.cookieBehavior" = 1;
        "privacy.clearOnShutdown.cookies" = true;
        "browser.newtabpage.enabled" = false;
        "browser.urlbar.oneOffSearches" = false;
        "browser.search.defaultenginename" = "bing";
      };
    };
  };
}
