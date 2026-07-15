#!/bin/bash

BRIGHT=$(brightnessctl -m | cut -d',' -f4 | tr -d '%')

dunstify \
    --stack-tag brightness \
    -h int:value:"$BRIGHT" \
    -i display-brightness \
    "󰃠 Brightness" "${BRIGHT}%"
