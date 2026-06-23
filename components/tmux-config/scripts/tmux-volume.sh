#!/bin/bash
# Volume widget — dynamic icon only.
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

vol=$(osascript -e "output volume of (get volume settings)" 2>/dev/null) || exit 0
muted=$(osascript -e "output muted of (get volume settings)" 2>/dev/null) || exit 0

if [ "$muted" = "true" ]; then
    printf '#[fg=#6c7086,bg=#1e1e2e]󰝟 '
elif [ "$vol" -ge 67 ]; then
    printf '#[fg=#f38ba8,bg=#1e1e2e]󰕾 '
elif [ "$vol" -ge 34 ]; then
    printf '#[fg=#f9e2af,bg=#1e1e2e]󰖀 '
else
    printf '#[fg=#a6e3a1,bg=#1e1e2e]󰕿 '
fi
