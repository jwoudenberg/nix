#!/usr/bin/env bash

# A script for starting the process defined by a Procfile in a new kitty window,
# with each process getting its own tab. Call it like this:
#
#     procfile ./path/to/Procfile
#
# This requires the Kitty config option allow_remote_control=yes to be set:
# https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.allow_remote_control
#
# Procfile documentation can be found here:
# https://devcenter.heroku.com/articles/procfile

set -euo pipefail

PROCFILE="${1:?'Pass a Procfile'}"

TARGET=("--type" "os-window" "--window-title" "$(realpath "$PROCFILE")")

launchCommand () {
  LINE="$1"
  CMD_NAME="${LINE%%:*}"
  CMD="${LINE#*:}"
  kitty @ launch "${TARGET[@]}" \
    --tab-title "$CMD_NAME" \
    --cwd current \
    --copy-env \
    bash -c "$CMD" \
    > /dev/null
  TARGET=("--match" "window_title:$PROCFILE" "--type" "tab")
}

while read -r line; do launchCommand "$line"; done < "$PROCFILE"
