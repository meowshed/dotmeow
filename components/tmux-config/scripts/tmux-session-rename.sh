#!/bin/bash
# Rename the current session, with suggestions — the session counterpart to
# tmux-window-rename.sh.
#
# A session is one workspace here, so the useful names come from where its
# active pane sits: the directory, the git repository, the branch.
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"

readonly DIM=$'\033[38;5;242m'
readonly RST=$'\033[0m'
readonly TAB=$'\t'

row() {
    [ -n "$1" ] || return 0
    printf '%s\t%s%s%s\n' "$1" "$DIM" "$2" "$RST"
}

name=$(tmux display-message -p '#{session_name}')
path=$(tmux display-message -p '#{pane_current_path}')

{
    row "$name" 'current name — press Tab to edit'
    row "$(basename "$path")" 'directory'
    if repo=$(git -C "$path" rev-parse --show-toplevel 2>/dev/null); then
        row "$(basename "$repo")" 'git repository'
        branch=$(git -C "$path" symbolic-ref --quiet --short HEAD 2>/dev/null)
        [ -n "$branch" ] && row "$(basename "$repo")/$branch" 'repository/branch'
    fi
} | awk -F'\t' '!seen[$1]++' >"${TMPDIR:-/tmp}/tmux-srename.$$"

out=$(fzf --ansi --border=none --height=100% --no-sort --print-query \
    --delimiter="$TAB" --with-nth=1,2 \
    --prompt '  ' \
    --header " Rename session $name — type a name, or pick one below" \
    --bind 'tab:replace-query' \
    <"${TMPDIR:-/tmp}/tmux-srename.$$")
status=$?
rm -f "${TMPDIR:-/tmp}/tmux-srename.$$"

case $status in
    0 | 1) ;;
    *) exit 0 ;;
esac

query=$(printf '%s\n' "$out" | sed -n 1p)
choice=$(printf '%s\n' "$out" | sed -n 2p)
value=${choice:+$(printf '%s' "$choice" | cut -d"$TAB" -f1)}
value=${value:-$query}

[ -n "$value" ] || exit 0
# tmux rejects a session name containing a dot or colon.
tmux rename-session "${value//[.:]/-}"
