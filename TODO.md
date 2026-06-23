# TODO

## tmux: `@resurrect-strategy-nvim "session"` requires nvim session plugin

tmux-resurrect restores nvim using the `Session.vim` file in each pane's CWD.
This only works if the nvim session was explicitly saved before detach.
Ensure meowvim includes a session-management plugin (e.g., persistence.nvim or
auto-session) that auto-saves on exit.

## Fish startup: cache `meowctl shell fish` output

`components/fish-config/conf.d/00-environment.fish` runs `meowctl shell fish | source` on
every new shell (every new pane, every split). This forks a process, initialises mise,
starship, zoxide, and direnv, and pipes the result back to source. If meowctl is slow or
the binary is cold in disk cache, every pane open adds latency.

Mitigation: write the generated fish code to `~/.cache/meowctl/shell-init.fish` on first
run and source the file directly on subsequent shells. Invalidate the cache on meowctl
version bump or dotmeow update. The cache file could be regenerated in the background
after sourcing to keep it fresh without blocking startup.
