# TODO

## Fish startup: cache `meowctl shell fish` output

`components/fish-config/conf.d/00-environment.fish` runs `meowctl shell fish | source` on
every new shell (every new pane, every split). This forks a process, initialises mise,
starship, zoxide, and direnv, and pipes the result back to source. If meowctl is slow or
the binary is cold in disk cache, every pane open adds latency.

Mitigation: write the generated fish code to `~/.cache/meowctl/shell-init.fish` on first
run and source the file directly on subsequent shells. Invalidate the cache on meowctl
version bump or dotmeow update. The cache file could be regenerated in the background
after sourcing to keep it fresh without blocking startup.

## tmux: hardcoded `/opt/homebrew/bin/fish` in `default-shell`

`tmux.conf` sets `default-shell /opt/homebrew/bin/fish` which is Apple Silicon only.
On Intel or Linux this breaks silently. tmux doesn't support shell substitution in `set`
values, so the path cannot be resolved dynamically in the config file itself.

Mitigation: have `tmux-config/init.star install()` detect the fish path via
`ctx.run("which", ["fish"])` and write a machine-local `~/.config/tmux/local.conf` that
overrides `default-shell`; include it from `tmux.conf` via
`if-shell "test -f ~/.config/tmux/local.conf" "source ~/.config/tmux/local.conf"`.

## tmux: `@resurrect-strategy-nvim "session"` requires nvim session plugin

tmux-resurrect restores nvim using the `Session.vim` file in each pane's CWD.
This only works if the nvim session was explicitly saved before detach.
Ensure meowvim includes a session-management plugin (e.g., persistence.nvim or
auto-session) that auto-saves on exit.

## tmux: `sysctl debug.lowpri_throttle_enabled=0` not persistent

Set in `macos-defaults/init.star` via `sudo sysctl`, but resets on every reboot.
To persist: add `debug.lowpri_throttle_enabled=0` to `/etc/sysctl.conf` or create a
LaunchDaemon plist that runs the sysctl command at boot.

## karabiner: ISO keyboard type is hardcoded

`karabiner.json` sets `"keyboard_type": "iso"` globally. This breaks ANSI keyboard users.
Consider making keyboard type a per-device condition or prompting during `meowctl apply`
and generating a machine-local karabiner snippet via `local.star`.

## starship: `[mise]` module shows on every prompt

The mise module now only activates when `.mise.toml` or `mise.toml` is present in the
project. For projects without explicit mise configs but with active tool versions (e.g.,
via parent directory or global defaults), the module will still be hidden. Consider whether
the `detect_folders = [".mise"]` option should also be included to catch older mise setups.

## Components missing `verify()` functions

Custom components have no post-install health checks. Adding minimal `verify()` functions
(e.g., check that symlinks exist and targets are present) would surface broken installs
early during `meowctl apply --verify`.

## tmux-config: `pbcopy` bindings break on non-macOS

`tmux.conf` is linked without a `platforms = ["macos"]` restriction, but the copy-mode
`y` binding (via tmux-yank), the `Y` binding, the tmux-thumbs `@thumbs-command`, and
related clipboard integrations all hardcode macOS `pbcopy`. On Linux or WSL these
bindings silently produce no clipboard copy.

Mitigation: either restrict `tmux-config` to `platforms = ["macos"]`, or use tmux-yank's
`@override_copy_command` to select `xclip -selection clipboard` on Linux. Alternatively,
generate a platform-specific snippet via `init.star install()`.

## glow: style does not follow Catppuccin Mocha theme

Every other tool uses Catppuccin Mocha. `glow.yml` sets `style: "dark"`, which is the
generic glamour dark palette (blue/purple tones, unrelated to mocha). The Catppuccin
project publishes a glow style at `catppuccin/glow`.

Mitigation: download `catppuccin-mocha.json` into `glow-config/`, link it via `init.star`,
and set `style: "catppuccin-mocha"` in `glow.yml`.

## karabiner: GUI writes back through symlink, silently dirtying the repo

`karabiner.json` is a symlink into the dotmeow repo. When Karabiner-Elements saves any
GUI change (enabling a modification, adding a device rule), it writes directly through the
symlink into the repo file, creating an uncommitted dirty state in the working tree.
An unsuspecting `git add -A && git commit` captures unreviewed GUI-generated JSON.

Mitigation options: (a) document this explicitly with a comment in `init.star` and rely
on `git diff` discipline; (b) use a `local.star` that copies rather than symlinks, using
the repo version as the read-only source of truth; (c) limit the symlink to only the
`assets/complex_modifications/` subdirectory and let Karabiner manage the top-level file.

## fish-config: shell abbreviations silently override interactive additions

`30-aliases.fish` calls `abbr --add ...` on every shell startup. Fish's `abbr --add` flag
overwrites any existing abbreviation with the same trigger silently, even if the user
added a custom one interactively during a previous session.

Mitigation: guard each `abbr --add` with `abbr --query <trigger> ||` to avoid overwriting
existing entries, or document that all custom abbreviations should live in `99-local.fish`.
