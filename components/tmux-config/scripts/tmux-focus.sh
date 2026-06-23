#!/bin/bash
# Outputs the active macOS Focus mode as a catppuccin-mocha tmux segment.
# Reads ~/Library/DoNotDisturb/DB/Assertions.json via plutil (no Python dep).
# Empty output = no active Focus mode.
# stderr suppressed — fails gracefully if the file is missing or schema changes.
# /bin/bash is Bash 3.2 on macOS; no Bash 4+ features used.
set -eo pipefail

db=~/Library/DoNotDisturb/DB/Assertions.json
[ -f "$db" ] || exit 0

# Extract the mode identifier of the first active assertion via plutil.
mode_id=$(plutil -extract 'data.0.storeAssertionRecords.0.assertionDetails.assertionDetailsModeIdentifier' raw "$db" 2>/dev/null) || exit 0
[ -n "$mode_id" ] || exit 0

case "$mode_id" in
    com.apple.donotdisturb.mode.default)    icon="󰂶"; label="DND"         ;;
    com.apple.sleep.sleep-mode)             icon="󰒲"; label="Sleep"        ;;
    com.apple.focus.work)                   icon="󰢾"; label="Work"         ;;
    com.apple.focus.personal)               icon="󱗽"; label="Personal"     ;;
    com.apple.focus.gaming)                 icon="󰊗"; label="Gaming"       ;;
    com.apple.focus.mindfulness)            icon="󰓏"; label="Mindfulness"  ;;
    com.apple.focus.reduce-interruptions)   icon="󱑙"; label="Focus"        ;;
    *)
        icon="󱑙"
        # Derive a human-readable label from the last component of the reverse-DNS id.
        label=$(printf '%s' "$mode_id" | awk -F. '{s=$NF; print toupper(substr(s,1,1)) substr(s,2)}')
        ;;
esac

printf '#[fg=#cba6f7,bg=#1e1e2e]%s %s  ' "$icon" "$label"
