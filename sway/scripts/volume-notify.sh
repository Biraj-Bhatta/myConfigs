#!/bin/bash

VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -n1)
MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

if [ "$MUTE" = "yes" ]; then
    dunstify --stack-tag volume "󰖁 Muted"
else
    dunstify \
        --stack-tag volume \
        -h int:value:$VOL \
        "󰕾 Volume" "$VOL%"
fi
