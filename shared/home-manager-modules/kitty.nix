{ pkgs, ... }: {
  programs.kitty = {
    enable = true;

    font = {
      name = "Fira Code";
      package = pkgs.fira-code;
    };

    settings = {
      shell = "${pkgs.fish}/bin/fish";
      tab_bar_edge = "top";
      tab_bar_style = "separator";
      tab_separator = " | ";
      macos_quit_when_last_window_closed = true;
      scrollback_pager =
        "nvim -c 'set ft=man' -c 'autocmd VimEnter * normal G' -";
    };

    keybindings = {
      "cmd+k" = "next_tab";
      "cmd+j" = "previous_tab";
      "ctrl+c" = "copy_or_interrupt";
      "ctrl+v" = "paste";
    };
  };
}
