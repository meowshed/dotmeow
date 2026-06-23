#!/bin/bash
# Outputs CPU usage as a catppuccin-mocha tmux segment.
# Only shown when usage >= 60% (matches original zjstatus-widgets threshold).
# Yellow 60-89%, red 90%+.
#
# Uses ps -A to sum per-process CPU snapshots divided by logical CPU count.
# Fast (no top), but instantaneous rather than averaged — may spike briefly.
set -eo pipefail

num_cpus=$(sysctl -n hw.logicalcpu 2>/dev/null) || exit 0
cpu_total=$(ps -A -o %cpu= 2>/dev/null | awk '{sum += $1} END {printf "%.0f", sum}')

{ [ -z "$cpu_total" ] || [ -z "$num_cpus" ]; } && exit 0

pct=$(awk -v total="$cpu_total" -v cpus="$num_cpus" 'BEGIN {printf "%d", total / cpus}')
[ "$pct" -lt 60 ] && exit 0

if [ "$pct" -ge 90 ]; then
    color="#f38ba8"
else
    color="#f9e2af"
fi

printf '#[fg=%s,bg=#1e1e2e]󰻠 %d%%%%  ' "$color" "$pct"
