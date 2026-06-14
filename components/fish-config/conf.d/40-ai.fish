# ~/.config/fish/conf.d/40-ai.fish
# Lightweight launch helpers for Claude, OpenCode, and Codex.

if status is-interactive
    function __ai_tools
        for tool in claude opencode codex
            if command -q $tool
                echo $tool
            end
        end
    end

    function __ai_pick_tool
        set -l available (__ai_tools)
        if test (count $available) -eq 0
            echo "No AI CLI found. Install one of: claude, opencode, codex" >&2
            return 1
        end

        if test (count $available) -eq 1
            echo $available[1]
            return 0
        end

        if command -q fzf
            set -l picked (printf '%s\n' $available | fzf --height=40% --prompt='ai> ')
            test -n "$picked"; or return 1
            echo $picked
        else
            echo $available[1]
        end
    end

    function __ai_resolve
        set -l first $argv[1]
        if contains -- $first claude opencode codex
            if not command -q $first
                echo "$first is not installed or not on PATH" >&2
                return 1
            end
            echo $first
            return 0
        end

        __ai_pick_tool
    end

    function ai --description 'Run Claude, OpenCode, or Codex in the current pane'
        set -l tool (__ai_resolve $argv)
        or return 1

        set -l args $argv
        if contains -- $args[1] claude opencode codex
            set -e args[1]
        end

        command $tool $args
    end

    function ait --description 'Open Claude, OpenCode, or Codex in a new Zellij tab'
        set -l tool (__ai_resolve $argv)
        or return 1

        set -l args $argv
        if contains -- $args[1] claude opencode codex
            set -e args[1]
        end

        if test -n "$ZELLIJ"
            zellij action new-tab --cwd "$PWD" --name "$tool" -- $tool $args
        else
            command $tool $args
        end
    end

    function aip --description 'Open Claude, OpenCode, or Codex in a floating Zellij pane'
        set -l tool (__ai_resolve $argv)
        or return 1

        set -l args $argv
        if contains -- $args[1] claude opencode codex
            set -e args[1]
        end

        if test -n "$ZELLIJ"
            zellij run --floating --near-current-pane --cwd "$PWD" --name "$tool" \
                --width 45% --height 80% --x 55% --y 10% -- $tool $args
        else
            command $tool $args
        end
    end
end
