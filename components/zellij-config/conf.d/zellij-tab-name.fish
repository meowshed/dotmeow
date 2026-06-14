# MIT License
#
# Copyright (c) 2025 Andrew Vasilyev <me@retran.me>
#
# @file: components/zellij/config/fish/conf.d/zellij-tab-name.fish
# @brief: Auto-rename zellij tabs based on current directory and running command.
#         Format: "dirname" at shell prompt, "dirname | cmd" while command runs.
#         Auto-naming is suppressed when the tab has a pinned (user-defined) name.
#
#         Also sets the terminal window/tab title via fish_title so that the
#         host terminal (WezTerm, Ghostty, iTerm2, etc.) shows the CWD.
#
# @author: Andrew Vasilyev
# @license: MIT
#
# Pin detection
#   On every fish_prompt we query `zellij action current-tab-info --json` to
#   get the current tab name.  If the name doesn't match what we last set,
#   the user renamed it manually — we pin automatically and stop overwriting.
#
#   Because we use `rename-tab --tab-id`, multiple panes in the same tab no
#   longer race: every pane targets the same stable tab ID rather than
#   whichever tab happens to be focused at the moment of the IPC call.
#
# User-facing function `zt`:
#   zt <name>   — rename tab and pin it (disables auto-naming)
#   zt -p       — pin current name without renaming
#   zt -r       — unpin (re-enables auto-naming)

# ── Terminal window/tab title (fish_title / fish_tab_title) ──────────────────
# fish_title      — window title (shown in the OS title bar)
# fish_tab_title  — terminal tab strip (fish 4.x; overrides fish_title for tabs)
#
# Both use git-aware directory: if inside a git repo, show the repo name
# instead of the raw CWD basename.  This is far more useful when working
# across multiple projects.
#
# argv[1] is the currently running foreground command (set by fish).

function __title_dir
    # If inside a git repo, use the repo root basename; otherwise prompt_pwd.
    set -l root (command git rev-parse --show-toplevel 2>/dev/null)
    if test -n "$root"
        echo (basename $root)
    else
        prompt_pwd --full-length-dirs 1
    end
end

function fish_title
    set -l dir (__title_dir)
    if set -q argv[1]
        echo "$dir | $argv[1]"
    else
        echo $dir
    end
end

# fish 4.x: separate tab-strip title (does not affect the window title bar).
function fish_tab_title
    set -l dir (__title_dir)
    if set -q argv[1]
        echo "$dir | $argv[1]"
    else
        echo $dir
    end
end

# ── Zellij tab naming ─────────────────────────────────────────────────────────

if status is-interactive
    and test -n "$ZELLIJ"

    # Per-tab state (fish variables, naturally scoped to this shell instance).
    # _zellij_tab_id    — stable numeric ID of our tab (queried once at startup)
    # _zellij_tab_name  — the last name we set (used to detect manual renames)
    # ZELLIJ_TAB_PINNED — non-empty means auto-naming is suppressed

    # Returns the git-aware short name suitable for the tab title.
    # Inside a git repo: repo root basename.  Otherwise: cwd basename.
    function __zellij_tab_dir
        set -l root (command git rev-parse --show-toplevel 2>/dev/null)
        if test -n "$root"
            basename "$root"
        else
            basename "$PWD"
        end
    end

    # Resolve and cache the tab ID for this pane.
    # Uses current-tab-info --json; falls back to empty string on failure.
    function __zellij_tab_id
        if not set -q _zellij_tab_id
            set -g _zellij_tab_id (zellij action current-tab-info --json 2>/dev/null \
                | string match -r '"tab_id":\s*(\d+)' \
                | tail -1 \
                | string replace -r '.*(\d+).*' '$1')
        end
        echo $_zellij_tab_id
    end

    # Rename our tab by its stable ID (not by focus).
    function __zellij_tab_rename
        set -l id (__zellij_tab_id)
        set -l name (string join ' ' -- $argv)
        test -n "$name"; or return
        if set -q _zellij_tab_name
            and test "$name" = "$_zellij_tab_name"
            return
        end
        set -l rename_status 1
        if test -n "$id"
            zellij action rename-tab --tab-id "$id" "$name" 2>/dev/null
            set rename_status $status
        else
            zellij action rename-tab "$name" 2>/dev/null
            set rename_status $status
        end
        if test $rename_status -eq 0
            set -g _zellij_tab_name $name
        end
    end

    # Query the current tab name from zellij.
    function __zellij_tab_current_name
        zellij action current-tab-info --json 2>/dev/null \
            | string match -r '"name":\s*"([^"]+)"' \
            | tail -1 \
            | string replace -r '^"name":\s*"(.+)"$' '$1'
    end

    # Detect manual rename: if the live tab name differs from what we last set,
    # the user renamed it via the zellij keybind — auto-pin.
    function __zellij_check_pin
        test -n "$ZELLIJ_TAB_PINNED"; and return
        # If we've never set a name yet, nothing to compare against.
        set -q _zellij_tab_name; or return
        set -l live (__zellij_tab_current_name)
        if test -n "$live" -a "$live" != "$_zellij_tab_name"
            set -gx ZELLIJ_TAB_PINNED 1
        end
    end

    function __zellij_command_name
        set -l line (string trim -- $argv[1])
        test -n "$line"; or return

        # Keep the tab useful for compound commands without trying to be a full shell parser.
        set -l first (string split -m1 -- '|' $line)[1]
        set first (string split -m1 -- ';' $first)[1]
        set first (string trim -- $first)

        set -l parts (string split ' ' -- $first | string match -rv '^\s*$')
        while test (count $parts) -gt 0
            set -l head (string trim -c "\"'" -- $parts[1])

            if string match -rq '^[A-Za-z_][A-Za-z0-9_]*=' -- $head
                set -e parts[1]
                continue
            end

            switch $head
                case command builtin exec nohup time
                    set -e parts[1]
                    continue
                case sudo
                    set -e parts[1]
                    while test (count $parts) -gt 0
                        set -l opt (string trim -c "\"'" -- $parts[1])
                        string match -rq '^-' -- $opt; or break
                        set -e parts[1]
                    end
                    continue
                case env
                    set -e parts[1]
                    while test (count $parts) -gt 0
                        set -l env_part (string trim -c "\"'" -- $parts[1])
                        if string match -rq '^-' -- $env_part
                            set -e parts[1]
                            continue
                        end
                        if string match -rq '^[A-Za-z_][A-Za-z0-9_]*=' -- $env_part
                            set -e parts[1]
                            continue
                        end
                        break
                    end
                    continue
            end

            break
        end

        test (count $parts) -gt 0; or return
        basename (string trim -c "\"'" -- $parts[1])
    end

    # Before a command executes: show "dir | cmd" (unless pinned).
    function __zellij_preexec --on-event fish_preexec
        __zellij_check_pin
        test -n "$ZELLIJ_TAB_PINNED"; and return
        set -l dir (__zellij_tab_dir)
        set -l cmd (__zellij_command_name $argv[1])
        test -n "$cmd"; or return
        __zellij_tab_rename "$dir | $cmd"
    end

    # After a command finishes / at prompt: show just "dir" (unless pinned).
    # Also checks for manual rename and auto-pins if detected.
    function __zellij_prompt --on-event fish_prompt
        __zellij_check_pin
        test -n "$ZELLIJ_TAB_PINNED"; and return
        __zellij_tab_rename (__zellij_tab_dir)
    end

    # Initialise tab ID and set initial name on shell startup.
    __zellij_tab_id >/dev/null
    __zellij_tab_rename (__zellij_tab_dir)

    # Public function for managing tab name pinning.
    #
    # zt <name>   rename tab and pin it
    # zt -p       pin without renaming
    # zt -r       unpin and immediately apply auto-name
    function zt --description "Manage zellij tab name (pin/unpin)"
        switch $argv[1]
            case -r --reset
                set -e ZELLIJ_TAB_PINNED
                set -e _zellij_tab_name
                __zellij_tab_rename (__zellij_tab_dir)
            case -p --pin
                set -gx ZELLIJ_TAB_PINNED 1
            case ''
                echo "Usage: zt <name>   — rename and pin"
                echo "       zt -p       — pin current name"
                echo "       zt -r       — unpin (restore auto-naming)"
            case '*'
                set -gx ZELLIJ_TAB_PINNED 1
                __zellij_tab_rename $argv
        end
    end

end
