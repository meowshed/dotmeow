#!/bin/bash
# Reads active macOS Focus mode and writes it to tmux option @tmux_focus_val.
# Called by the launchd event agent on DoNotDisturb Assertions.json change.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
set -eo pipefail

db="$HOME/Library/DoNotDisturb/DB/Assertions.json"
if [ ! -f "$db" ]; then
    tmux set-option -g @tmux_focus_val "" 2>/dev/null || true
    exit 0
fi

mode_id=$(plutil -extract \
    'data.0.storeAssertionRecords.0.assertionDetails.assertionDetailsModeIdentifier' \
    raw "$db" 2>/dev/null) || {
    tmux set-option -g @tmux_focus_val "" 2>/dev/null || true
    exit 0
}
if [ -z "$mode_id" ]; then
    tmux set-option -g @tmux_focus_val "" 2>/dev/null || true
    exit 0
fi

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

tmux set-option -g @tmux_focus_val \
    "$(printf '#[fg=#cba6f7,bg=#1e1e2e]%s %s  ' "$icon" "$label")" 2>/dev/null || true
