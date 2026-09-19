#!/bin/bash
# Fuzzy palette over every tmux command, in place of the bare `:` prompt.
#
# list-commands prints each command with its argument syntax, which doubles as
# the description — so this cannot drift from the tmux build in use.
# Enter puts the command on tmux's own prompt rather than running it, since most
# of them need arguments.
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"

readonly DIM=$'\033[38;5;242m'
readonly RST=$'\033[0m'

selected=$(tmux list-commands |
    awk -v dim="$DIM" -v rst="$RST" '{
        name = $1
        args = ""
        for (i = 2; i <= NF; i++) args = args " " $i
        printf "%s\t%s%s%s\n", name, dim, args, rst
    }' | sort |
    fzf --ansi --border=none --height=100% --no-sort \
        --delimiter='\t' --with-nth=1,2 \
        --prompt '  ' \
        --header ' tmux commands — Enter puts it on the prompt')

[ -n "$selected" ] || exit 0
tmux command-prompt -I "${selected%%	*} "
