{ pkgs, lib, ... }:
{
  environment.systemPackages = [ pkgs.nushell ];

  # Seed ~/.config/nushell/history.txt with persisted history commands.
  # Using `home.file.<name>.*` would create an unmodifiable symlink.
  system.userActivationScripts.link-nushell-history.text = ''
    CONFIG_DIR="/home/jasper/.config/nushell"
    mkdir -p "$CONFIG_DIR"
    ln -sf "/home/jasper/docs/nushell-history.txt" "$CONFIG_DIR/history.txt"
  '';

  homedir.files = {
    ".config/nushell/env.nu" = pkgs.writeText "env.nu" ''
      $env.PROMPT_COMMAND = { pwd | path basename }
      $env.PROMPT_COMMAND_RIGHT = {
              do --ignore-errors { git branch }
                | complete
                | get stdout
                | grep '^* '
                | str substring 2..
            }
      $env.PROMPT_INDICATOR = ' '
      $env.PROMPT_INDICATOR_VI_INSERT = ' '
      $env.PROMPT_INDICATOR_VI_NORMAL = ' '
      $env.PROMPT_MULTILINE_INDICATOR = ' '
    '';

    ".config/nushell/config.nu" = pkgs.writeText "config.nu" ''
      $env.config = {
        show_banner: false
        edit_mode: vi
        table: { mode: compact }
        render_right_prompt_on_last_line: true
        keybindings: [{
          name: unix-line-discard
          modifier: control
          keycode: char_u
          mode: [emacs, vi_insert, vi_normal]
          event: { until: [{edit: cutfromlinestart}] }
        }, {
          name: insert-file-using-fzf
          modifier: control
          keycode: char_t
          mode: [emacs, vi_insert, vi_normal]
          event: { send: ExecuteHostCommand, cmd: "commandline edit --insert (fzf)" }
        }, {
          name: menu-left
          modifier: control
          keycode: char_h
          mode: [emacs, vi_insert, vi_normal]
          event: { until: [{send: MenuLeft}] }
        }, {
          name: menu-right
          modifier: control
          keycode: char_l
          mode: [emacs, vi_insert, vi_normal]
          event: { until: [{send: MenuRight}] }
        }, {
          name: menu-up
          modifier: control
          keycode: char_k
          mode: [emacs, vi_insert, vi_normal]
          event: { until: [{send: MenuUp}] }
        }, {
          name: menu-down
          modifier: control
          keycode: char_j
          mode: [emacs, vi_insert, vi_normal]
          event: { until: [{send: MenuDown}] }
        }]
        hooks: {
          pre_prompt: [{ ||
            if (which direnv | is-empty) {
              return
            }
            direnv export json | from json | default {} | load-env
          }]
          env_change: {
            PWD: { random-colors }
          }
        }
      }

      def remind [--months (-m): int = 1] {
        cat ~/hjgames/agenda/*agenda.txt | ${pkgs.agenda-txt}/bin/agenda-txt ($"*($months)m")
      }

      # Display events for today
      ^echo (cat ~/hjgames/agenda/*agenda.txt | ${pkgs.agenda-txt}/bin/agenda-txt *1d)

      alias agenda = ^$env.EDITOR ~/hjgames/agenda/agenda.txt
      alias ssh = kitty +kitten ssh
      alias todo = ^$env.EDITOR ~/docs/todo.txt
      alias surf = ${../home-manager-modules/nushell/surf.nu}
      alias work = ${../home-manager-modules/nushell/work.nu}
      alias zet = ${../home-manager-modules/nushell/zet.nu}
      alias procfile = ${../home-manager-modules/procfile/procfile.sh}
    '';
  };
}
