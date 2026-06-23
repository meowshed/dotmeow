#!/bin/bash
# Outputs a VPN indicator if any utun/ppp/ipsec interface carries a routable IPv4.
# macOS creates utun0-utun3 for iCloud/Continuity with only link-local IPv6 —
# those are excluded. A real VPN tunnel (WireGuard, IKEv2, OpenVPN) has a
# routable IPv4 (not 127.x or 169.254.x).
# /bin/bash is Bash 3.2 on macOS; no Bash 4+ features used.
set -eo pipefail

active=$(ifconfig 2>/dev/null | awk '
    # iface is used as a boolean flag only (value not inspected).
    /^(utun|ppp|ipsec)[0-9]+:/ { iface = 1 }
    /^\tinet [0-9]/ {
        if (iface && $2 !~ /^127\./ && $2 !~ /^169\.254\./) { print "vpn"; exit }
    }
    /^[a-z]/ { iface = 0 }
')

[ -z "$active" ] && exit 0

printf '#[fg=#f38ba8,bg=#1e1e2e]󰖂 VPN  '
