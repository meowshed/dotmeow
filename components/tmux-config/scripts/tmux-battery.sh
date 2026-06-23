#!/bin/bash
# Battery widget — dynamic colored icon only, no percentage text.
set -eo pipefail

batt=$(pmset -g batt 2>/dev/null) || exit 0
pct=$(echo "$batt" | grep -o '[0-9]*%' | head -1 | tr -d '%')
[ -z "$pct" ] && exit 0

_color_for_pct() {
    if   [ "$1" -ge 80 ]; then printf '#a6e3a1'
    elif [ "$1" -ge 60 ]; then printf '#94e2d5'
    elif [ "$1" -ge 40 ]; then printf '#f9e2af'
    elif [ "$1" -ge 20 ]; then printf '#fab387'
    else                       printf '#f38ba8'
    fi
}

color=$(_color_for_pct "$pct")

if echo "$batt" | grep -q 'AC Power'; then
    [ "$pct" -eq 100 ] && icon="󰁹" || icon="󰂄"
else
    if [ "$pct" -le 10 ]; then
        icon="󰂃"
    else
        icons=("󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")
        level=$(( pct / 10 ))
        icon="${icons[$level]}"
    fi
fi

printf '#[fg=%s,bg=#1e1e2e]%s ' "$color" "$icon"
