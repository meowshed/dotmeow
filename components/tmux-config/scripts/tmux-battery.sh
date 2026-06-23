#!/bin/bash
# Battery widget matching zjstatus-widgets color/icon scheme.
# Always shown (including 100% on AC). Per-level icons when discharging.
# Bash 3.2 arrays are safe on macOS /bin/bash.
set -eo pipefail

batt=$(pmset -g batt 2>/dev/null) || exit 0
pct=$(echo "$batt" | grep -o '[0-9]*%' | head -1 | tr -d '%')
[ -z "$pct" ] && exit 0

if echo "$batt" | grep -q 'AC Power'; then
    # Use percentage rather than the status string to handle all AC states
    # ("charged", "finishing charge", etc.) uniformly.
    if [ "$pct" -eq 100 ]; then
        icon="󰁹"; color="#a6e3a1"
    else
        icon="󰂄"; color="#a6e3a1"
    fi
else
    if [ "$pct" -le 10 ]; then
        icon="󰂃"; color="#f38ba8"
    else
        icons=("󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")
        level=$(( pct / 10 ))
        [ "$level" -gt 10 ] && level=10
        icon="${icons[$level]}"
        if [ "$pct" -le 30 ]; then
            color="#fab387"
        else
            color="#f9e2af"
        fi
    fi
fi

printf '#[fg=%s,bg=#1e1e2e]%s %d%%%%  ' "$color" "$icon" "$pct"
