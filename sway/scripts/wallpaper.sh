#!/bin/bash

# Define your two wallpaper directories here
DIR1="$HOME/.local/share/backgrounds/normal/"
DIR2="$HOME/.local/share/backgrounds/zun/"

# File to track which directory and image you are currently on
STATE_FILE="$HOME/.cache/sway_wallpaper_state"

# Slideshow settings
SLIDESHOW_INTERVAL=30
SLIDESHOW_PID_FILE="${XDG_RUNTIME_DIR:-/tmp}/sway_wallpaper_slideshow.pid"
SCRIPT="$(readlink -f "$0")"

# Ensure bash reads file extensions case-insensitively and handles empty dirs gracefully
shopt -s nullglob nocaseglob

# Read the saved state if it exists, otherwise initialize to DIR1
read_state() {
    if [[ -f "$STATE_FILE" ]]; then
        source "$STATE_FILE"
    else
        CURRENT_DIR="$DIR1"
        CURRENT_INDEX=0
    fi
}

# Save the current state to the cache file
save_state() {
    echo "CURRENT_DIR=\"$CURRENT_DIR\"" > "$STATE_FILE"
    echo "CURRENT_INDEX=$CURRENT_INDEX" >> "$STATE_FILE"
}

# Apply the wallpaper using swaymsg
apply_wallpaper() {
    images=("$CURRENT_DIR"/*.{jpg,jpeg,png,webp})
    num_images=${#images[@]}

    if [[ $num_images -eq 0 ]]; then
        echo "No images found in $CURRENT_DIR"
        save_state
        exit 1
    fi

    if (( CURRENT_INDEX >= num_images )); then
        CURRENT_INDEX=0
    elif (( CURRENT_INDEX < 0 )); then
        CURRENT_INDEX=$(( num_images - 1 ))
    fi

    selected_image="${images[$CURRENT_INDEX]}"

    swaymsg "output * bg \"$selected_image\" fill"
    save_state
}

# Is the slideshow loop currently running?
slideshow_running() {
    [[ -f "$SLIDESHOW_PID_FILE" ]] && kill -0 "$(cat "$SLIDESHOW_PID_FILE")" 2>/dev/null
}

# Start/stop the slideshow
toggle_slideshow() {
    if slideshow_running; then
        # Kill the whole process group (loop + its sleep)
        kill -- -"$(cat "$SLIDESHOW_PID_FILE")" 2>/dev/null
        rm -f "$SLIDESHOW_PID_FILE"
        command -v notify-send >/dev/null && notify-send "Wallpaper slideshow" "Stopped"
    else
        # setsid gives the loop its own process group so it can be killed cleanly
        setsid -f "$SCRIPT" _loop >/dev/null 2>&1
        command -v notify-send >/dev/null && notify-send "Wallpaper slideshow" "Started (every ${SLIDESHOW_INTERVAL}s)"
    fi
}

read_state

# Handle the command line arguments
case "$1" in
    toggle)
        if [[ "$CURRENT_DIR" == "$DIR1" ]]; then
            CURRENT_DIR="$DIR2"
        else
            CURRENT_DIR="$DIR1"
        fi
        CURRENT_INDEX=0
        apply_wallpaper
        ;;
    next)
        images=("$CURRENT_DIR"/*.{jpg,jpeg,png,webp})
        num_images=${#images[@]}
        if [[ $num_images -gt 0 ]]; then
            CURRENT_INDEX=$(( (CURRENT_INDEX + 1) % num_images ))
            apply_wallpaper
        fi
        ;;
    prev)
        images=("$CURRENT_DIR"/*.{jpg,jpeg,png,webp})
        num_images=${#images[@]}
        if [[ $num_images -gt 0 ]]; then
            CURRENT_INDEX=$(( (CURRENT_INDEX - 1 + num_images) % num_images ))
            apply_wallpaper
        fi
        ;;
    init)
        apply_wallpaper
        ;;
    slideshow)
        toggle_slideshow
        ;;
    _loop)
        # Internal: the background loop started by "slideshow"
        echo $$ > "$SLIDESHOW_PID_FILE"
        while true; do
            sleep "$SLIDESHOW_INTERVAL"
            "$SCRIPT" next
        done
        ;;
    *)
        echo "Usage: $0 {toggle|next|prev|init|slideshow}"
        exit 1
        ;;
esac
