{ pkgs, ... }: {
  programs.kitty = {
    enable = true;

    font = {
      name = "Fira Code";
      package = pkgs.fira-code;
    };

    settings = {
      font_size = if builtins.currentSystem == "x86_64-darwin" then 18 else 14;
      shell = "${pkgs.fish}/bin/fish";
      tab_bar_edge = "top";
      tab_bar_style = "separator";
      tab_separator = " | ";
      macos_quit_when_last_window_closed = true;
    };

    keybindings = {
      "cmd+k" = "next_tab";
      "cmd+j" = "previous_tab";
    };
  };
}
