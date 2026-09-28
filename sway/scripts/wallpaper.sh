#!/bin/bash

# Define your two wallpaper directories here
DIR1="$HOME/.local/share/backgrounds/normal/"
DIR2="$HOME/.local/share/backgrounds/zun/"

# File to track which directory and image you are currently on
STATE_FILE="$HOME/.cache/sway_wallpaper_state"

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
    # Grab all images in the active directory
    images=("$CURRENT_DIR"/*.{jpg,jpeg,png,webp})
    num_images=${#images[@]}

    if [[ $num_images -eq 0 ]]; then
        echo "No images found in $CURRENT_DIR"
        # FIX: Save state so it remembers we toggled, even if empty!
        save_state
        exit 1
    fi

    # Keep index within bounds if directory contents have changed
    if (( CURRENT_INDEX >= num_images )); then
        CURRENT_INDEX=0
    elif (( CURRENT_INDEX < 0 )); then
        CURRENT_INDEX=$(( num_images - 1 ))
    fi

    selected_image="${images[$CURRENT_INDEX]}"

    # Apply using sway IPC
    swaymsg "output * bg \"$selected_image\" fill"
    save_state
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
        # Just restore the last used wallpaper
        apply_wallpaper
        ;;
    *)
        echo "Usage: $0 {toggle|next|prev|init}"
        exit 1
        ;;
esac
