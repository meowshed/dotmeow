#!/bin/bash
# VPN indicator (poll path). Delegates to push script to keep
# detection logic in one place; reads the cached tmux option value.
SCRIPTS_DIR="$(dirname "$0")"
"$SCRIPTS_DIR/tmux-vpn-push.sh" 2>/dev/null || true
tmux show-option -gv @tmux_vpn_val 2>/dev/null || true
