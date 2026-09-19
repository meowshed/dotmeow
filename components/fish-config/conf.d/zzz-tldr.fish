# ~/.config/fish/conf.d/zzz-tldr.fish
# tldr — pick a page with fzf and preview it, Ctrl-B.
#
# The counterpart to Ctrl-O (navi): navi pastes a command onto the line, this
# one is for reading. Ctrl-O and Ctrl-B are the only single Ctrl keys left free
# in this setup. `tldr --list` is the local cache, so no network on each key.

status is-interactive; or return
command -q tldr; or return

function __tldr_widget --description 'Browse tldr pages with fzf'
    set -l page (tldr --list 2>/dev/null | fzf \
        --height=60% --reverse --border=rounded \
        --prompt '  ' \
        --header ' tldr pages' \
        --preview 'tldr --color always {}' \
        --preview-window 'right,65%,border-left')
    if test -n "$page"
        commandline -r "tldr $page"
        commandline -f execute
    else
        commandline -f repaint
    end
end

# Named keys, and no 2>/dev/null: a silenced bind failure is invisible.
for mode in default insert
    bind -M $mode ctrl-b __tldr_widget
end
