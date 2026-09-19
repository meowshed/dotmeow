#!/bin/bash
# Open a centred floating pane.
#
#   tmux-float.sh <width%> <height%> [command ...]
#
# new-pane takes absolute sizes and positions only: `-x 70%` sizes right but
# leaves the top-left corner at the window centre, and `-X C -Y C` is rejected.
# The border takes one cell per side, hence the +2.
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"

wpct="${1:-80}"
hpct="${2:-60}"
shift 2 2>/dev/null

win_w=$(tmux display-message -p '#{window_width}')
win_h=$(tmux display-message -p '#{window_height}')
cwd=$(tmux display-message -p '#{pane_current_path}')

pane_w=$((win_w * wpct / 100))
pane_h=$((win_h * hpct / 100))

# Clamp to the window; fall back to full size when the fraction is too small.
max_w=$((win_w - 2))
max_h=$((win_h - 2))
[ "$pane_w" -gt "$max_w" ] && pane_w=$max_w
[ "$pane_h" -gt "$max_h" ] && pane_h=$max_h
[ "$pane_w" -lt 20 ] && pane_w=$max_w
[ "$pane_h" -lt 6 ] && pane_h=$max_h

x=$(((win_w - pane_w) / 2))
y=$(((win_h - pane_h) / 2))
[ "$x" -lt 1 ] && x=1
[ "$y" -lt 1 ] && y=1

tmux new-pane -c "$cwd" -x "$pane_w" -y "$pane_h" -X "$x" -Y "$y" "$@"
