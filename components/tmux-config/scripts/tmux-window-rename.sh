#!/bin/bash
# Window rename UI — an fzf popup instead of tmux's bare command-prompt.
#
#   tmux-window-rename.sh           rename the current window
#   tmux-window-rename.sh --pick    choose a window first, then rename it
#
# Suggestions come from the pane: cwd, running command, git repo and branch.
# Enter takes whatever is typed; Tab loads a suggestion in for editing.
#
# "automatic" restores automatic-rename; any other choice calls rename-window,
# which clears it — what the format in post-tpm.conf keys off.
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"

readonly DIM=$'\033[38;5;242m'
readonly RST=$'\033[0m'
readonly TAB=$'\t'

# A name that adds nothing over the cwd — mirrors @_wn_shell in post-tpm.conf.
is_shell() {
    case "$1" in
        fish | bash | zsh | sh) return 0 ;;
        *) return 1 ;;
    esac
}

# row <value> <label> [kind]
row() {
    [ -n "$1" ] || return 0
    printf '%s\t%s%s%s\t%s\n' "$1" "$DIM" "$2" "$RST" "${3:-name}"
}

pick_window() {
    local out
    out=$(tmux list-windows -F \
        "#{window_index}${TAB}#{?window_active,● ,  }#{window_name}${TAB}#{pane_current_command}" |
        awk -F'\t' -v dim="$DIM" -v rst="$RST" \
            'BEGIN { OFS = "\t" } { $3 = dim $3 rst; print }' |
        fzf \
            --ansi --border=none --height=100% --no-sort --delimiter="$TAB" --with-nth=1,2,3 \
            --prompt '  ' \
            --header ' Rename which window?')
    [ -n "$out" ] && printf '%s' "${out%%$TAB*}"
}

target=""
if [ "$1" = "--pick" ]; then
    target=$(pick_window)
    [ -n "$target" ] || exit 0
else
    target=$(tmux display-message -p '#{window_index}')
fi

name=$(tmux display-message -p -t "$target" '#{window_name}')
path=$(tmux display-message -p -t "$target" '#{pane_current_path}')
cmd=$(tmux display-message -p -t "$target" '#{pane_current_command}')

# ── Suggestions ──────────────────────────────────────────────────────────────
# Built into a list of "value <TAB> label <TAB> kind" rows; only value and label
# are displayed, kind is read back after the selection.
{
    row "$name" 'current name — press Tab to edit'
    row "$(basename "$path")" 'directory'
    is_shell "$cmd" || row "$cmd" 'running command'

    if repo=$(git -C "$path" rev-parse --show-toplevel 2>/dev/null); then
        row "$(basename "$repo")" 'git repository'
        branch=$(git -C "$path" symbolic-ref --quiet --short HEAD 2>/dev/null)
        row "$branch" 'git branch'
        [ -n "$branch" ] && row "$(basename "$repo")/$branch" 'repository/branch'
    fi

    parent=$(basename "$(dirname "$path")")
    [ "$parent" != "/" ] && row "$parent/$(basename "$path")" 'parent/directory'

    row 'automatic' 'follow cwd and command again' 'auto'
} | awk -F'\t' '!seen[$1]++' >"${TMPDIR:-/tmp}/tmux-rename.$$"

# Plain fzf: the binding already opened a floating pane. --height=100% overrides
# the --height=40% in FZF_DEFAULT_OPTS.
out=$(fzf \
    --ansi --border=none --height=100% --no-sort --print-query \
    --delimiter="$TAB" --with-nth=1,2 \
    --prompt '  ' \
    --header " Rename window $target — type a name, or pick one below" \
    --bind 'tab:replace-query' \
    <"${TMPDIR:-/tmp}/tmux-rename.$$")
status=$?
rm -f "${TMPDIR:-/tmp}/tmux-rename.$$"

# 0 = a row was selected, 1 = no row matched but the query stands. Anything
# else (130 abort, 2 error) means the user backed out.
case $status in
    0 | 1) ;;
    *) exit 0 ;;
esac

query=$(printf '%s\n' "$out" | sed -n 1p)
choice=$(printf '%s\n' "$out" | sed -n 2p)

if [ -n "$choice" ]; then
    value=$(printf '%s' "$choice" | cut -d"$TAB" -f1)
    kind=$(printf '%s' "$choice" | cut -d"$TAB" -f3)
else
    value="$query"
    kind="name"
fi

[ -n "$value" ] || exit 0

if [ "$kind" = "auto" ]; then
    tmux set-window-option -t "$target" automatic-rename on
    tmux display-message "window $target: automatic naming restored"
else
    tmux rename-window -t "$target" "$value"
fi
exit 0
