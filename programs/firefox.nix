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
        "browser.newtabpage.enabled" = false;
        "signon.rememberSignons" = false;
      };
    };
  };
}
