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
      shell_integration = "enabled";
      scrollback_pager =
        "nvim -R -c 'colors noctu | set laststatus=0 nonumber | silent write! /tmp/kitty_scrollback_buffer | te cat /tmp/kitty_scrollback_buffer -'";

    };

    keybindings = {
      "ctrl+shift+k" = "next_tab";
      "ctrl+shift+j" = "previous_tab";
      "ctrl+shift+t" = "new_tab_with_cwd";
    };

    extraConfig = ''
      mouse_map left click ungrabbed mouse_click_url_or_select
      copy_on_select no
      mouse_map middle release ungrabbed paste_from_clipboard
    '';
  };
}
