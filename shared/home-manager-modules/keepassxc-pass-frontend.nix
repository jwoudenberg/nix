{ pkgs, config, ... }: {
  home.packages = [ pkgs.keepassxc-pass-frontend ];
  home.sessionVariables.KEEPASSXC_PASSWORD_DB =
    "${config.home.homeDirectory}/docs/passwords.kdbx";
}
