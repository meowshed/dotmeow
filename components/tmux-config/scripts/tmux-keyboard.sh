#!/bin/bash
# Outputs current keyboard layout as a catppuccin-mocha tmux segment.
# Polled by tmux every status-interval (5 s). Empty output = widget hidden.
# /bin/bash is Bash 3.2 on macOS; no Bash 4+ features used.
set -eo pipefail

layout=$(defaults read "$HOME/Library/Preferences/com.apple.HIToolbox.plist" \
    AppleCurrentKeyboardLayoutInputSourceID 2>/dev/null)

[ -z "$layout" ] && exit 0

# Extract the last dotted component of the layout ID for the fallback label,
# e.g. com.apple.keylayout.Dvorak → Dvorak.
last_component=$(echo "$layout" | sed 's/.*\.\([^.]*\)$/\1/')

case "$layout" in
    *Russian*)          label="RU" ;;
    *ABC* | *\.US)      label="EN" ;;
    *USInternational*)  label="EN" ;;
    *British*)          label="EN" ;;
    *Australian*)       label="EN" ;;
    *)                  label="$last_component" ;;
esac

printf '#[fg=#89b4fa,bg=#1e1e2e]󰌌 %s  ' "$label"
