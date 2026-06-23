#!/bin/bash
# VPN indicator — outputs a catppuccin-mocha tmux segment when a VPN is active.
# Polled every status-interval seconds.

active=$(ifconfig 2>/dev/null | awk '
    /^(utun|ppp|ipsec)[0-9]+:/ { iface = 1 }
    /^\tinet [0-9]/ {
        if (iface && $2 !~ /^127\./ && $2 !~ /^169\.254\./) { print "vpn"; exit }
    }
    /^[a-z]/ { iface = 0 }
')

[ -n "$active" ] && printf '#[fg=#cba6f7,bg=#1e1e2e]󰖂 '
