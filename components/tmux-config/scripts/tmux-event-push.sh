#!/bin/bash
# Runs all event-driven widget push scripts and refreshes the tmux status bar.
# Invoked by the launchd agent (me.retran.tmux-event-refresh) on file-system
# changes or every 30 s (StartInterval). Uses an atomic mkdir lock so
# concurrent invocations (e.g. multiple client-attached hooks) collapse into one.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

lockdir="/tmp/tmux-event-push-${UID}.lock"
mkdir "$lockdir" 2>/dev/null || exit 0
trap 'rmdir "$lockdir" 2>/dev/null' EXIT

DIR="$HOME/.config/tmux/scripts"
"$DIR/tmux-keyboard-push.sh" 2>/dev/null || true
"$DIR/tmux-focus-push.sh"    2>/dev/null || true
"$DIR/tmux-vpn-push.sh"      2>/dev/null || true
tmux refresh-client -S 2>/dev/null || true
