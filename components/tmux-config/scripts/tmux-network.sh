#!/bin/bash
# Network widget — icon only. WiFi or Ethernet, red when disconnected.
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin"

primary=$(route -n get default 2>/dev/null | awk '/interface:/ {print $2}')
[ -z "$primary" ] && { printf '#[fg=#f38ba8,bg=#1e1e2e]󰤭 '; exit 0; }

ip=$(ipconfig getifaddr "$primary" 2>/dev/null)
[ -z "$ip" ] && { printf '#[fg=#f38ba8,bg=#1e1e2e]󰤭 '; exit 0; }

wifi_dev=$(networksetup -listallhardwareports 2>/dev/null | awk '/Wi-Fi/{f=1} f && /Device:/{print $2; exit}')
if [ "$primary" = "$wifi_dev" ]; then
    printf '#[fg=#89b4fa,bg=#1e1e2e]󰤨 '
else
    printf '#[fg=#89b4fa,bg=#1e1e2e]󰈀 '
fi
