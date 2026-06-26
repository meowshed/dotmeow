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

    # Erase meowctl's once-only shell-init guard before exec, so the tmux server is
    # born with a clean environment. Otherwise every continuum-restored pane inherits
    # _MEOWCTL_SHELL_DONE at server boot, `meowctl shell fish` skips `meowctl hook
    # shell`, and starship/mise/zoxide/direnv never initialise in restored panes.
    set -e _MEOWCTL_SHELL_DONE
    exec tmux new-session -A -s main
end
