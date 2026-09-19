#!/bin/bash
# Copy-mode search from a floating pane.
#
#   tmux-search.sh <pane-id> <forward|backward>
#
# The pane id is captured by the binding, because by the time this runs the
# floating pane is the active one and `send -X` would go to the wrong place.
# Matches the old binding's behaviour: not incremental, one search on Enter.
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"

pane="$1"
direction="$2"
[ -n "$pane" ] || exit 0

label='search down'
[ "$direction" = "backward" ] && label='search up'

term=$(printf '' | fzf --border=none --height=100% --print-query \
    --prompt '  ' --header " $label" 2>/dev/null | sed -n 1p)

[ -n "$term" ] || exit 0
tmux send-keys -X -t "$pane" "search-$direction" "$term"
