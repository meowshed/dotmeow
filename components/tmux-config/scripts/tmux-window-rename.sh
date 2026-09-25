#!/bin/bash
# Window rename UI — an fzf popup instead of tmux's bare command-prompt.
#
#   tmux-window-rename.sh           rename the current window
#   tmux-window-rename.sh --pick    choose a window first, then rename it
#
# The input starts with the window's current label, ready to edit. Enter takes
# the input exactly as typed; Tab copies the highlighted suggestion into it.
# An empty input restores automatic naming.
#
# Suggestions come from the pane you work in: cwd, running command, git repo
# and branch. The popup is itself a floating pane and the active one, so the
# script reads the tiled pane that was active before it.
#
# rename-window clears automatic-rename, which is what the format in
# post-tpm.conf keys off; restoring sets it again.
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

# row <value> <label>
row() {
    [ -n "$1" ] || return 0
    printf '%s\t%s%s%s\n' "$1" "$DIM" "$2" "$RST"
}

# Prints the window id; the index is only shown.
pick_window() {
    local out
    out=$(tmux list-windows -F \
        "#{window_id}${TAB}#{window_index}${TAB}#{?window_active,● ,  }#{window_name}" |
        fzf \
            --ansi --border=none --height=100% --no-sort --delimiter="$TAB" --with-nth=2,3 \
            --prompt '  ' \
            --header ' Rename which window?')
    [ -n "$out" ] && printf '%s' "${out%%$TAB*}"
}

# The tiled pane of a window that is active, or was active before a float took
# focus.
work_pane() {
    tmux list-panes -t "$1" -F '#{pane_floating_flag}#{pane_active}#{pane_last} #{pane_id}' |
        awk '$1 == "010" { a = $2 } $1 == "001" { l = $2 } END { print (a != "" ? a : l) }'
}

target=""
if [ "$1" = "--pick" ]; then
    target=$(pick_window)
    [ -n "$target" ] || exit 0
else
    target=$(tmux display-message -p '#{window_id}')
fi

pane=$(work_pane "$target")
[ -n "$pane" ] || pane="$target"

index=$(tmux display-message -p -t "$target" '#{window_index}')
name=$(tmux display-message -p -t "$target" '#{window_name}')
# tmux keeps a literal #[ as ##[ so it can't act as a style; undo that here,
# or saving the prefilled name again would double it.
name=${name//'##['/'#['}
auto=$(tmux display-message -p -t "$target" '#{automatic-rename}')
path=$(tmux display-message -p -t "$pane" '#{pane_current_path}')
cmd=$(tmux display-message -p -t "$pane" '#{pane_current_command}')

dir=$(basename "$path")
label="$dir"
is_shell "$cmd" || label="$dir | $cmd"

# What the tab shows now: the manual name, or the automatic label.
if [ "$auto" = "1" ]; then
    current="$label"
else
    current="$name"
fi

# ── Suggestions ──────────────────────────────────────────────────────────────
# Rows of "value <TAB> label"; only the value is ever read back.
{
    row "$current" 'current name'
    row "$label" 'directory | command'
    row "$dir" 'directory'
    is_shell "$cmd" || row "$cmd" 'running command'

    if repo=$(git -C "$path" rev-parse --show-toplevel 2>/dev/null); then
        row "$(basename "$repo")" 'git repository'
        branch=$(git -C "$path" symbolic-ref --quiet --short HEAD 2>/dev/null)
        row "$branch" 'git branch'
        [ -n "$branch" ] && row "$(basename "$repo")/$branch" 'repository/branch'
    fi

    parent=$(basename "$(dirname "$path")")
    [ "$parent" != "/" ] && row "$parent/$dir" 'parent/directory'
} | awk -F'\t' '!seen[$1]++' >"${TMPDIR:-/tmp}/tmux-rename.$$"

# Plain fzf: the binding already opened a floating pane. --height=100% overrides
# the --height=40% in FZF_DEFAULT_OPTS. --disabled keeps the list whole while
# you type, since the input is a name and not a search.
out=$(fzf \
    --ansi --border=none --height=100% --no-sort --disabled \
    --delimiter="$TAB" --with-nth=1,2 \
    --query "$current" \
    --prompt '  ' \
    --header " Rename window $index — Enter keeps the input, Tab copies a suggestion, empty = automatic" \
    --bind 'enter:print-query' \
    --bind 'tab:transform-query:printf %s {1} | tr -d "\t"' \
    <"${TMPDIR:-/tmp}/tmux-rename.$$")
status=$?
rm -f "${TMPDIR:-/tmp}/tmux-rename.$$"

# 130 = Esc, anything else non-zero = error; either way leave the name alone.
[ "$status" -eq 0 ] || exit 0

if [ -z "$out" ]; then
    tmux set-window-option -t "$target" automatic-rename on
    tmux display-message "window $index: automatic naming restored"
else
    # rename-window expands formats in its argument, so a literal # is ##.
    # -- lets a name start with a dash.
    tmux rename-window -t "$target" -- "${out//#/##}"
fi
exit 0
