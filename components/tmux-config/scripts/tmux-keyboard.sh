#!/bin/bash
# Keyboard layout — shown only when layout is RU.
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

layout=$(defaults read "$HOME/Library/Preferences/com.apple.HIToolbox.plist" \
    AppleCurrentKeyboardLayoutInputSourceID 2>/dev/null) || exit 0

[[ "$layout" == *Russian* ]] || exit 0

printf '#[fg=#89b4fa,bg=#1e1e2e]󰌌 RU '
