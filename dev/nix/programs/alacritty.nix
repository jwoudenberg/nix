{ pkgs, ... }: {
  programs.alacritty = {
    enable = true;

    settings = {
      window = {
        dynamic_padding = true;
        startup_mode = "Maximized";
      };

      font = {
        normal = { family = "Fira Code"; };
        bold = { family = "Fira Code"; };
        italic = { family = "Fira Code"; };
        size = 13;
      };
    };
  };
}
