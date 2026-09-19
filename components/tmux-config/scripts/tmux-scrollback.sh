#!/bin/bash
# Open the calling pane's scrollback in neovim, in a floating pane.
#
# fuzzback (prefix F) searches the scrollback; this hands it to an editor. The
# capture happens before the floating pane exists — once open it is the active
# pane, and capture-pane would grab the editor instead.
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"

dir="${TMPDIR:-/tmp}/tmux-scrollback"
mkdir -p "$dir"

pane=$(tmux display-message -p '#{session_name}-#{window_index}.#{pane_index}')
file="$dir/${pane//[^A-Za-z0-9._-]/_}.log"

# -J unwraps lines that only wrapped because the pane is narrow, so a long
# command line comes back as one line instead of several.
tmux capture-pane -p -J -S -50000 >"$file"

# +$ starts at the bottom: the interesting part of a log is almost always the end.
exec ~/.config/tmux/scripts/tmux-float.sh 90 85 nvim "+$" "$file"
