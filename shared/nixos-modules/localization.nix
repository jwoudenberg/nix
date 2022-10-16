{ pkgs, ... }: {
  console.keyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
  };
  time.timeZone = "Europe/Amsterdam";
}
