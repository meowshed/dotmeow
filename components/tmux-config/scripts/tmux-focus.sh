#!/bin/bash
# Focus mode widget (poll path). Delegates to push script to keep
# detection logic in one place; reads the cached tmux option value.
SCRIPTS_DIR="$(dirname "$0")"
"$SCRIPTS_DIR/tmux-focus-push.sh" 2>/dev/null || true
tmux show-option -gv @tmux_focus_val 2>/dev/null || true
