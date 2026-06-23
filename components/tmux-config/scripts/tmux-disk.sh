#!/bin/bash
# Disk I/O widget — appears only when throughput exceeds 10 MB/s.
# Uses a cache file to compute delta between polls.
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

CACHE="/tmp/tmux-disk-${UID}"

current=$(ioreg -r -c IOBlockStorageDriver -k Statistics 2>/dev/null | \
    awk -F'= ' '/"Bytes \(Read\)"/ {r+=$2} /"Bytes \(Write\)"/ {w+=$2} END {print r+w}')
[ -z "$current" ] && exit 0

if [ -f "$CACHE" ]; then
    prev=$(cat "$CACHE")
    delta=$(( current - prev ))
    mb=$(awk "BEGIN {printf \"%d\", $delta / 1048576}")
    if [ "$mb" -ge 10 ]; then
        if   [ "$mb" -ge 100 ]; then color="#f38ba8"
        elif [ "$mb" -ge 50 ];  then color="#fab387"
        else                         color="#f9e2af"
        fi
        printf '#[fg=%s,bg=#1e1e2e]󰋊 %dM/s ' "$color" "$mb"
    fi
fi

printf '%s' "$current" > "$CACHE"
