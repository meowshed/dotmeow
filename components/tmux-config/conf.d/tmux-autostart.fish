# MIT License
#
# Copyright (c) 2025 Andrew Vasilyev <me@retran.me>
#
# @file: components/tmux-config/conf.d/tmux-autostart.fish
# @brief: Auto-start tmux on interactive fish login.
#         Attaches to the existing "main" session or creates a new one.
#         Guards on $TMUX to prevent nesting.
#         Limits to Ghostty terminal only (TERM_PROGRAM=Ghostty since 1.0).

if status is-interactive
    and command -q tmux
    and test -z "$TMUX"
    and test -z "$SSH_CONNECTION"
    and string match -qi "ghostty*" -- "$TERM_PROGRAM"

    exec tmux new-session -A -s main
end
