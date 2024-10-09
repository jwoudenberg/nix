{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.fzf ];

  homedir.sessionVariables = {
    FZF_DEFAULT_COMMAND = "${pkgs.ripgrep}/bin/rg --hidden --iglob !.git --files";
  };
}
