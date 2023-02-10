#!/usr/bin/env bash

# A script for starting the process defined by a Procfile in a new kitty window,
# with each process getting its own tab. Call it like this:
#
#     procfile ./path/to/Procfile
#
# Procfile documentation can be found here:
# https://devcenter.heroku.com/articles/procfile

set -euo pipefail

PROCFILE="${1:-Procfile}"
SOCKET="unix:/tmp/kittyprocfile"

launch_line () {
  local LINE="$1"
  local CMD_NAME="${LINE%%:*}"
  local CMD="${LINE#*:}"
  kitty @ --to "$SOCKET" launch \
    --type tab \
    --tab-title "$CMD_NAME" \
    --cwd current \
    --copy-env \
    --hold \
    bash -c "$CMD" \
    > /dev/null
}
export -f launch_line

kitty \
  -o allow_remote_control=socket-only \
  --listen-on "$SOCKET" \
  --title "$(realpath "$PROCFILE")" \
  bash -c "while read -r line; do launch_line \"\$line\"; done < \"$PROCFILE\"" \
  &>/dev/null \ &
