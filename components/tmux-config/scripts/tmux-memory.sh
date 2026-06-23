#!/bin/bash
# Outputs memory pressure as a catppuccin-mocha tmux segment.
# Only shown when usage >= 70% (matches original zjstatus-widgets threshold).
# Yellow 70-89%, red 90%+.
# /bin/bash is Bash 3.2 on macOS; no Bash 4+ features used.
set -eo pipefail

vm_stat_output=$(vm_stat 2>/dev/null) || exit 0

# vm_stat field positions (macOS): "Mach Virtual Memory Statistics: (page size of N bytes)"
# Line examples:
#   Pages active:              1234.
#   Pages wired down:          5678.   <- field $4
#   Pages occupied by compressor:  123.   <- field $5
page_size=$(echo "$vm_stat_output" | awk '/page size of/ {print $8}')
active=$(echo    "$vm_stat_output" | awk '/Pages active:/              {gsub(/\./,"",$3); print $3}')
wired=$(echo     "$vm_stat_output" | awk '/Pages wired/               {gsub(/\./,"",$4); print $4}')
compressed=$(echo "$vm_stat_output" | awk '/Pages occupied by compressor/ {gsub(/\./,"",$5); print $5}')

# Exit if the two required fields are missing; wired/compressed default to 0 below.
{ [ -z "$page_size" ] || [ -z "$active" ]; } && exit 0

total_bytes=$(sysctl -n hw.memsize 2>/dev/null) || exit 0

used_bytes=$(( (${active} + ${wired:-0} + ${compressed:-0}) * ${page_size} ))
pct=$(( used_bytes * 100 / total_bytes ))

[ "$pct" -lt 70 ] && exit 0

used_gib=$(awk -v b="$used_bytes" 'BEGIN {printf "%.1f", b / 1073741824}')

if [ "$pct" -ge 90 ]; then
    color="#f38ba8"
else
    color="#f9e2af"
fi

printf '#[fg=%s,bg=#1e1e2e]󰍛 %sG  ' "$color" "$used_gib"
