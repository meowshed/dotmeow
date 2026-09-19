#!/bin/bash
# Yes/no dialog in a floating pane.
#
#   tmux-confirm.sh "<question>" "<tmux command>"
#
# Replaces confirm-before, which asks in the status line where the question is
# easy to miss and a stray keypress answers it. Here the destructive choice is
# never the one under the cursor.
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"

question="$1"
command="$2"
[ -n "$command" ] || exit 0

choice=$(printf 'no\nyes\n' | fzf \
    --ansi --border=none --height=100% --no-sort --no-info \
    --pointer='>' \
    --prompt '  ' \
    --header "$question")

[ "$choice" = "yes" ] || exit 0

script="${TMPDIR:-/tmp}/tmux-confirm.$$"
printf '%s\n' "$command" >"$script"
tmux source-file "$script"
rm -f "$script"
