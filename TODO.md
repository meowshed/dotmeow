# TODO

## Zellij tab-naming plugin

Move the tab auto-naming logic from `components/zellij-config/conf.d/zellij-tab-name.fish`
into a native zellij wasm plugin to eliminate all `zellij action` subprocess spawns from fish.

**Current approach (throttled polling):**
- Fish calls `zellij action rename-tab` on every prompt/preexec when the name changes.
- Pin detection polls `zellij action current-tab-info --json` once every 5 s per pane.
- With many panes open this still produces periodic process bursts.

**Target architecture:**
- Fish sends a single lightweight pipe message per prompt/preexec:
  `zellij pipe --name "tab-namer" -- "dir=<dir> cmd=<cmd>"`
- Plugin receives the pipe, calls `rename_tab()` directly in Rust — no child process.
- Plugin subscribes to `TabUpdate` events to detect manual renames without polling.
- Plugin owns pin state per `tab_id`, shared across all panes in the same tab
  (removes the per-shell `ZELLIJ_TAB_PINNED` env var and the pane-race issue).

**What stays in fish:**
- Git root detection (`git rev-parse --show-toplevel`) — plugin sandbox disallows it.
- CWD tracking — only the shell knows its own working directory.
- Command name parsing (`__zellij_command_name`) — needs the `fish_preexec` event.

**Effort:** ~150-200 lines of Rust, `zellij-tile` crate, `wasm32-wasip1` target.
Register via `load_plugins` in `components/zellij-config/config.kdl` (same mechanism
as `zellij:link`).

---

## Fish startup: cache `meowctl shell fish` output

`components/fish-config/conf.d/00-environment.fish` runs `meowctl shell fish | source` on
every new shell (every new pane, every split). This forks a process, initialises mise,
starship, zoxide, and direnv, and pipes the result back to source. If meowctl is slow or
the binary is cold in disk cache, every pane open adds latency.

Mitigation: write the generated fish code to `~/.cache/meowctl/shell-init.fish` on first
run and source the file directly on subsequent shells. Invalidate the cache on meowctl
version bump or dotmeow update. The cache file could be regenerated in the background
after sourcing to keep it fresh without blocking startup.
