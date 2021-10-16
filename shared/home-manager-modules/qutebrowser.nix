{ pkgs, ... }: {
  programs.qutebrowser = {
    enable = true;
    aliases = {
      "q" = "tab-close";
      "tabnew" = "new-tab";
    };
    keyBindings.normal = {
      "<Ctrl-O>" = "back";
      "<Ctrl-I>" = "forward";
      "gt" = "tab-next";
      "gT" = "tab-prev";
    };
    settings = {
      downloads.location.directory = "~/downloads";
      downloads.location.prompt = false;
      spellcheck.languages = [ "en-US" "nl-NL" ];
      tabs.last_close = "close";
    };
  };
}
