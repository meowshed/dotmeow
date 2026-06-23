# ~/.config/fish/conf.d/25-terminal-title.fish
# Sets the terminal window/tab title to a git-aware CWD.
# Works in Ghostty, iTerm2, WezTerm, and any OSC-2-capable terminal.
# Independent of the multiplexer (tmux, zellij, or none).
#
# Format: "repo" at idle, "repo | cmd" while a command runs.
# Uses the git repo root basename inside a repo; otherwise prompt_pwd.
# Cache note: _title_git_cache_root is invalidated on $PWD change but not on
# git init / git clone in the current directory — requires a cd to refresh.

# Private helper: returns the git-root basename or abbreviated CWD.
function __title_dir
    if not set -q _title_git_cache_pwd
        or test "$_title_git_cache_pwd" != "$PWD"
        set -g _title_git_cache_pwd $PWD
        set -g _title_git_cache_root (command git rev-parse --show-toplevel 2>/dev/null)
    end
    if test -n "$_title_git_cache_root"
        basename "$_title_git_cache_root"
    else
        prompt_pwd --full-length-dirs 1
    end
end

# Private helper: formats the title string shared by fish_title and fish_tab_title.
function __title_format
    set -l dir (__title_dir)
    if set -q argv[1]
        echo "$dir | $argv[1]"
    else
        echo "$dir"
    end
end

# Inside tmux, ofirgall/tmux-window-name drives window naming; OSC-2 titles
# from fish_title pass through and can override it. Disable both hooks when
# running under tmux.
if not set -q TMUX
    # Window title shown in the OS title bar (all fish versions).
    function fish_title
        __title_format $argv
    end

    # Tab-strip title introduced in Fish 4.0; honored by Ghostty and other modern
    # terminals that distinguish window title from tab title.
    function fish_tab_title
        __title_format $argv
    end
end
