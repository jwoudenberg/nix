{ pkgs, ... }: {
  programs.alacritty = {
    enable = true;

    settings = {
      window = {
        dynamic_padding = true;
        startup_mode = "Maximized";
      };

      font = {
        normal = {
          family = "FiraCode";
        };
        bold = {
          family = "FiraCode";
        };
        italic = {
          family = "FiraCode";
        };
        size = 13;
      };
    };
  };
}
