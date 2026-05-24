# MIT License
#
# Copyright (c) 2025 Andrew Vasilyev <me@retran.me>
#
# @file: components/zellij-config/conf.d/zellij-autostart.fish
# @brief: Auto-start zellij on interactive fish login.
#         Uses exec to replace the fish process with zellij (no orphan prompt).
#         Guards on ZELLIJ env var (set inside any zellij pane) to prevent nesting.
#         Limits to Ghostty and Alacritty terminals only.

if status is-interactive
    and command -q zellij
    and test -z "$ZELLIJ"

    set -l _term "$TERM_PROGRAM"
    set -l _xterm "$TERM"

    if test "$_term" = Ghostty
        or test "$_term" = ghostty
        or test "$_xterm" = xterm-ghostty
        or test "$_xterm" = xterm-ghostty-256color
        or test "$_term" = Alacritty
        or test -n "$ALACRITTY_LOG"
        or test -n "$ALACRITTY_WINDOW_ID"

        set -e _MEOWCTL_SHELL_DONE
        exec zellij
    end
end
