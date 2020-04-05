#!/bin/fish

# Set vi keybindings.
fish_vi_key_bindings

# No greeting message.
set fish_greeting

function fish_mode_prompt
    # overwrite the default fish_mode_prompt to show nothing.
end

set -x MANPAGER "/bin/sh -c \"unset MANPAGER;col -b -x | \
    nvim -R -c 'set ft=man nomod nolist' -c 'map q :q<CR>' \
    -c 'map <SPACE> <C-D>' -c 'map b <C-U>' \
    -c 'nmap K :Man <C-R>=expand(\\\"<cword>\\\")<CR><CR>' -\""
