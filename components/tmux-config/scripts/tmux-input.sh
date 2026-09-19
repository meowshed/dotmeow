#!/bin/bash
# Read one line in a floating pane, then run a tmux command with it.
#
#   tmux-input.sh "<prompt>" "<initial>" "<tmux command with @@>"
#
# Replaces command-prompt, which draws over the status bar. @@ is replaced by
# what was typed; an empty answer or Escape does nothing.
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"

prompt="$1"
initial="$2"
template="$3"
[ -n "$template" ] || exit 0

# fzf with an empty list is a plain line editor: --print-query returns what was
# typed and nothing can be selected instead of it.
answer=$(printf '' | fzf --border=none --height=100% --print-query \
    --query "$initial" --prompt '  ' --header " $prompt" 2>/dev/null | sed -n 1p)

[ -n "$answer" ] || exit 0

script="${TMPDIR:-/tmp}/tmux-input.$$"
printf '%s\n' "${template//@@/$answer}" >"$script"
tmux source-file "$script"
rm -f "$script"
