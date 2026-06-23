#!/bin/bash
# Focus mode widget — outputs a catppuccin-mocha tmux segment when a Focus is active.
# Polled every status-interval seconds.

db="$HOME/Library/DoNotDisturb/DB/Assertions.json"
[ -f "$db" ] || exit 0

mode_id=$(plutil -extract \
    'data.0.storeAssertionRecords.0.assertionDetails.assertionDetailsModeIdentifier' \
    raw "$db" 2>/dev/null) || exit 0
[ -n "$mode_id" ] || exit 0

case "$mode_id" in
    com.apple.donotdisturb.mode.default)    icon="󰂶"; label="DND"        ;;
    com.apple.sleep.sleep-mode)             icon="󰒲"; label="Sleep"       ;;
    com.apple.focus.work)                   icon="󰢾"; label="Work"        ;;
    com.apple.focus.personal)               icon="󱗽"; label="Personal"    ;;
    com.apple.focus.gaming)                 icon="󰊗"; label="Gaming"      ;;
    com.apple.focus.mindfulness)            icon="󰓏"; label="Mindfulness" ;;
    com.apple.focus.reduce-interruptions)   icon="󱑙"; label="Focus"       ;;
    *)
        icon="󱑙"
        label=$(printf '%s' "$mode_id" | awk -F. '{s=$NF; print toupper(substr(s,1,1)) substr(s,2)}')
        ;;
esac

printf '#[fg=#cba6f7,bg=#1e1e2e]%s ' "$icon"
