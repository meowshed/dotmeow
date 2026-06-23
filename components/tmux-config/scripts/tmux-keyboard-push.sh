#!/bin/bash
# Reads current keyboard layout and writes it to tmux option @tmux_keyboard_val.
# Called by the launchd event agent on HIToolbox.plist change.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

layout=$(defaults read "$HOME/Library/Preferences/com.apple.HIToolbox.plist" \
    AppleCurrentKeyboardLayoutInputSourceID 2>/dev/null) || exit 0
[ -z "$layout" ] && exit 0

last=$(echo "$layout" | sed 's/.*\.\([^.]*\)$/\1/')
case "$layout" in
    *Russian*)              label="RU" ;;
    *ABC*|*\.US)            label="EN" ;;
    *USInternational*)      label="EN" ;;
    *British*|*Australian*) label="EN" ;;
    *)                      label="$last" ;;
esac

tmux set-option -g @tmux_keyboard_val \
    "$(printf '#[fg=#89b4fa,bg=#1e1e2e]󰌌 %s  ' "$label")" 2>/dev/null || true
