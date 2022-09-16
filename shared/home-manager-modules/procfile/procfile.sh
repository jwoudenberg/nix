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
LAUNCH=launchFirst

launchFirst () {
  local LINE="$1"
  local CMD_NAME="${LINE%%:*}"
  local CMD="${LINE#*:}"
  kitty \
    -o allow_remote_control=socket-only \
    --listen-on "$SOCKET" \
    --title "$(realpath "$PROCFILE")" \
    bash -c "$CMD" \
    &>/dev/null \ &
  sleep 1
  kitty @ --to "$SOCKET" set-tab-title "$CMD_NAME"
  LAUNCH=launchRest
}

launchRest () {
  local LINE="$1"
  local CMD_NAME="${LINE%%:*}"
  local CMD="${LINE#*:}"
  kitty @ --to "$SOCKET" \
    launch "${TARGET[@]}" \
    --type tab \
    --tab-title "$CMD_NAME" \
    --cwd current \
    --copy-env \
    bash -c "$CMD" \
    > /dev/null
}

while read -r line; do "$LAUNCH" "$line"; done < "$PROCFILE"
