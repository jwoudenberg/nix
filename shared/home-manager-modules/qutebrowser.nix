{ pkgs, ... }: {
  programs.qutebrowser = {
    enable = true;
    aliases = { "q" = "tab-close"; };
    keyBindings.normal = {
      "<Ctrl-O>" = "back";
      "<Ctrl-I>" = "forward";
      "gt" = "tab-next";
      "gT" = "tab-prev";
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
    };
  };
}
