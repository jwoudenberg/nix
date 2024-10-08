{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.fzf ];

  environment.variables = {
    FZF_DEFAULT_COMMAND = "${pkgs.ripgrep}/bin/rg --hidden --iglob !.git --files";
  };
}
