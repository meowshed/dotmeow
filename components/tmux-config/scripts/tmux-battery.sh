#!/bin/bash
# Outputs battery status as a catppuccin-mocha tmux segment.
# Shows percentage + charging indicator; hidden when on AC with full battery.
# /bin/bash is Bash 3.2 on macOS; no Bash 4+ features used.
set -eo pipefail

batt=$(pmset -g batt 2>/dev/null) || exit 0
pct=$(echo "$batt" | grep -o '[0-9]*%' | head -1 | tr -d '%')
[ -z "$pct" ] && exit 0

# On AC power and fully charged — nothing to show
echo "$batt" | grep -q 'AC Power' && [ "$pct" -eq 100 ] && exit 0

if echo "$batt" | grep -q 'charging\|AC Power'; then
    icon="󰂄"
    color="#a6e3a1"
elif [ "$pct" -le 10 ]; then
    icon="󰂃"
    color="#f38ba8"
elif [ "$pct" -le 30 ]; then
    icon="󰁼"
    color="#f9e2af"
else
    icon="󰁹"
    color="#a6e3a1"
fi

printf '#[fg=%s,bg=#1e1e2e]%s %d%%%%  ' "$color" "$icon" "$pct"
