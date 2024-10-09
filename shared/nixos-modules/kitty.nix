{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.kitty
    pkgs.fira-code
  ];

  homedir.files = {
    ".config/kitty/kitty.conf" = pkgs.writeText "kitty.conf" ''
      # See https://sw.kovidgoyal.net/kitty/conf.html
      font_family Fira Code
      font_size 12

      scrollback_pager nvim -R -c 'colors noctu | set laststatus=0 nonumber | silent write! /tmp/kitty_scrollback_buffer | te cat /tmp/kitty_scrollback_buffer -'
      shell ${pkgs.nushell}/bin/nu

      tab_bar_edge top
      tab_bar_style separator
      tab_separator  |

      map ctrl+c copy_and_clear_or_interrupt
      map ctrl+shift+j previous_tab
      map ctrl+shift+k next_tab
      map ctrl+shift+t new_tab_with_cwd
      map ctrl+v paste_from_clipboard

      mouse_map left click ungrabbed mouse_click_url_or_select
      copy_on_select no
      mouse_map middle release ungrabbed paste_from_clipboard
    '';
  };
}
