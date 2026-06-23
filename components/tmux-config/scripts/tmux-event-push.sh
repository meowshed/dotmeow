#!/bin/bash
# Runs all event-driven widget push scripts and refreshes the tmux status bar.
# Invoked by the launchd agent (me.retran.tmux-event-refresh) when any
# watched path changes: HIToolbox.plist, DoNotDisturb Assertions.json,
# or /Library/Preferences/SystemConfiguration (VPN/network changes).
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
DIR="$HOME/.config/tmux/scripts"
"$DIR/tmux-keyboard-push.sh" 2>/dev/null || true
"$DIR/tmux-focus-push.sh"    2>/dev/null || true
"$DIR/tmux-vpn-push.sh"      2>/dev/null || true
tmux refresh-client -S 2>/dev/null || true
