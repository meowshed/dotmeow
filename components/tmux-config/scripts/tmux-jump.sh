#!/bin/bash
# Jump to a window or pane in the CURRENT session.
#
# One session is one workspace here, so crossing sessions is `prefix w` (sesh).
# A single-pane window lists once; a split one lists its panes.
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"

readonly DIM=$'\033[38;5;242m'
readonly ACC=$'\033[38;5;110m'
readonly RST=$'\033[0m'
readonly TAB=$'\t'

session=$(tmux display-message -p '#{session_name}')

# target <TAB> display
# -f excludes the floating pane this script runs in.
rows=$(tmux list-panes -s -t "$session" -f '#{?pane_floating_flag,0,1}' -F \
    "#{window_index}.#{pane_index}${TAB}#{window_index}${TAB}#{window_name}${TAB}#{pane_current_command}${TAB}#{b:pane_current_path}${TAB}#{window_panes}${TAB}#{?window_active,1,0}#{?pane_active,1,0}" |
    awk -F"$TAB" -v OFS="$TAB" -v acc="$ACC" -v dim="$DIM" -v rst="$RST" '
    {
        target = $1; widx = $2; wname = $3; cmd = $4; dir = $5; panes = $6; active = $7
        here = (active == "11") ? "● " : "  "
        # A lone pane is just the window; a split one is worth addressing directly.
        label = (panes > 1) ? widx "." substr(target, index(target, ".") + 1) : widx
        print target, here acc label rst "  " wname, dim cmd "  " dir rst
    }')

[ -n "$rows" ] || exit 0

# Plain fzf: the binding already opened a floating pane. --height=100% overrides
# the --height=40% in FZF_DEFAULT_OPTS.
out=$(printf '%s\n' "$rows" | fzf \
    --ansi --border=none --height=100% --no-sort --delimiter="$TAB" --with-nth=2,3 --nth=1,2 \
    --prompt '  ' \
    --header "  Jump within $session" \
    --preview "tmux capture-pane -ep -t '{1}' 2>/dev/null | tail -40" \
    --preview-window 'right,55%,border-left')

[ -n "$out" ] || exit 0
target=${out%%$TAB*}

tmux select-window -t "${target%.*}"
tmux select-pane -t "$target"
exit 0
