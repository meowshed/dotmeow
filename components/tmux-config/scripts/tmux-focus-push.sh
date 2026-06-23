#!/bin/bash
# Reads active macOS Focus mode and writes it to tmux option @tmux_focus_val.
# Triggered by the launchd agent on DoNotDisturb Assertions.json change or every 30 s (StartInterval).
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

_clear() { tmux set-option -g @tmux_focus_val "" 2>/dev/null || true; }

db="$HOME/Library/DoNotDisturb/DB/Assertions.json"
[ -f "$db" ] || { _clear; exit 0; }

mode_id=$(plutil -extract \
    'data.0.storeAssertionRecords.0.assertionDetails.assertionDetailsModeIdentifier' \
    raw "$db" 2>/dev/null) || { _clear; exit 0; }
[ -n "$mode_id" ] || { _clear; exit 0; }

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
    "$(printf '#[fg=#cba6f7,bg=#1e1e2e]%s %s ' "$icon" "$label")" 2>/dev/null || true
