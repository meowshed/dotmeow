#!/bin/bash
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"

# Plain fzf: the binding already opened a floating pane. --height=100% overrides
# the --height=40% in FZF_DEFAULT_OPTS.
selected=$(sesh list --icons | fzf \
    --no-sort --ansi --border=none --height=100% \
    --prompt '  ' \
    --header ' Sessions' \
    --bind 'tab:down,btab:up')

[ -n "$selected" ] && sesh connect "$selected"
exit 0
