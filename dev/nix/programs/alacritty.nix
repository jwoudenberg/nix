{ pkgs, ... }: {
  programs.alacritty = {
    enable = true;

    settings = {
      shell.program = "${pkgs.fish}/bin/fish";

      window = {
        dynamic_padding = true;
        startup_mode = "Maximized";
      };

      font = {
        normal = { family = "Fira Code"; };
        bold = { family = "Fira Code"; };
        italic = { family = "Fira Code"; };
        size = if builtins.currentSystem == "x86_64-darwin" then 16 else 13;
      };
    };
  };
}
