#!/bin/bash
# Checks VPN state and writes it to tmux option @tmux_vpn_val.
# Triggered by the launchd agent on SystemConfiguration change or every 30 s (StartInterval).
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

active=$(ifconfig 2>/dev/null | awk '
    /^(utun|ppp|ipsec)[0-9]+:/ { iface = 1 }
    /^\tinet [0-9]/ {
        if (iface && $2 !~ /^127\./ && $2 !~ /^169\.254\./) { print "vpn"; exit }
    }
    /^[a-z]/ { iface = 0 }
')

if [ -n "$active" ]; then
    tmux set-option -g @tmux_vpn_val \
        "$(printf '#[fg=#f38ba8,bg=#1e1e2e]󰖂 VPN  ')" 2>/dev/null || true
else
    tmux set-option -g @tmux_vpn_val "" 2>/dev/null || true
fi
