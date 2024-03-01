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
    event: { send: ExecuteHostCommand, cmd: "commandline --insert (fzf)" }
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
