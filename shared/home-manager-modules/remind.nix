{ pkgs, ... }: {
  home.packages = [ pkgs.remind ];
  home.sessionVariables.DOTREMINDERS =
    "${config.home.homeDirectory}/docs/org/cal.rem";
}
