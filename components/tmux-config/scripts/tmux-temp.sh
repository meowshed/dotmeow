#!/bin/bash
# Temperature widget — appears only above 70°C. Requires osx-cpu-temp.
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

command -v osx-cpu-temp >/dev/null 2>&1 || exit 0

temp=$(osx-cpu-temp 2>/dev/null | grep -o '[0-9]*\.[0-9]*' | head -1 | cut -d. -f1)
[ -z "$temp" ] && exit 0
[ "$temp" -lt 70 ] && exit 0

if   [ "$temp" -ge 95 ]; then color="#f38ba8"
elif [ "$temp" -ge 85 ]; then color="#fab387"
else                          color="#f9e2af"
fi

printf '#[fg=%s,bg=#1e1e2e]󰔐 %d° ' "$color" "$temp"
