#!/bin/sh
# Next tiled window opens on the right of whatever is focused.
hyprctl dispatch 'hl.dsp.layout("preselect r")' >/dev/null 2>&1
exec kitty "$@"
