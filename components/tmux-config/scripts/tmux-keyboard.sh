#!/bin/bash
# Keyboard layout widget (poll path). Delegates to push script to keep
# detection logic in one place; reads the cached tmux option value.
SCRIPTS_DIR="$(dirname "$0")"
"$SCRIPTS_DIR/tmux-keyboard-push.sh" 2>/dev/null || true
tmux show-option -gv @tmux_keyboard_val 2>/dev/null || true
