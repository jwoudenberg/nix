{ pkgs, ... }: {
  programs.kitty = {
    enable = true;

    font = {
      name = "Fira Code";
      package = pkgs.fira-code;
    };

    settings = {
      font_size = 18;
      shell = "${pkgs.fish}/bin/fish";
      tab_bar_edge = "top";
      tab_bar_style = "separator";
      tab_separator = " | ";
    };

    keybindings = {
      "ctrl+c" = "copy_or_interrupt";
      "ctrl+v" = "paste_from_clipboard";
      "ctrl+k" = "clear_terminal clear active";
    };
  };
}
