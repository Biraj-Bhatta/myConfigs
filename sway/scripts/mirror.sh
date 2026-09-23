#!/bin/bash

## For Sway
PRI_MON="eDP-1"

SEC_MON=$(swaymsg -t get_outputs |
    jq -r --arg pri "$PRI_MON" \
    '.[] | select(.name != $pri) | .name ' |
    fzf --prompt "Which to monitor")

if [ -z "$SEC_MON" ]; then
    echo "No monitor selected or found."
    exit 1
fi

swaymsg output "$PRI_MON" mode 1920x1080 position 0 0
swaymsg output "$SEC_MON" enable mode 1920x1080 position 0 0

