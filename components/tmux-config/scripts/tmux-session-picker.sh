#!/bin/bash
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"

selected=$(sesh list --icons | fzf-tmux -p 80%,60% \
    --no-sort --ansi \
    --prompt '  ' \
    --header ' Sessions' \
    --bind 'tab:down,btab:up')

[ -n "$selected" ] && sesh connect "$selected"
exit 0
