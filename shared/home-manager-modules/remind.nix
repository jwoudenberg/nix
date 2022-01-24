{ pkgs, ... }: {
  home.packages = [ pkgs.remind ];
  home.sessionVariables.DOTREMINDERS =
    "${config.home.homeDirectory}/hjgames/agenda/agenda.rem";
}
