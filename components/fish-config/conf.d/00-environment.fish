# ~/.config/fish/conf.d/00-environment.fish
# Core environment variables and PATH setup.
# Loaded before all other conf.d files.

# ---------------------------------------------------------------------------
# Locale
# ---------------------------------------------------------------------------
set -gx LC_ALL en_US.UTF-8

# ---------------------------------------------------------------------------
# PATH — user-local binaries first
# ---------------------------------------------------------------------------
if test -d $HOME/.local/bin
    fish_add_path $HOME/.local/bin
end

# ---------------------------------------------------------------------------
# Homebrew
# ---------------------------------------------------------------------------
set -gx HOMEBREW_NO_ANALYTICS 1

# Prepend Homebrew bin so brew-installed tools (bash 5, gnu coreutils, etc.)
# shadow macOS BSD versions. Must come before mise shims on PATH.
if test -d /opt/homebrew/bin
    fish_add_path -m /opt/homebrew/bin /opt/homebrew/sbin
end

# ---------------------------------------------------------------------------
# Pager — bat for man pages and general paging
# ---------------------------------------------------------------------------
if command -q bat
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
    set -gx PAGER bat
else
    set -gx PAGER less
end

# ---------------------------------------------------------------------------
# Editor
# ---------------------------------------------------------------------------
set -gx EDITOR nvim
set -gx VISUAL nvim

# ---------------------------------------------------------------------------
# Disable greeting
# ---------------------------------------------------------------------------
set -g fish_greeting

# ---------------------------------------------------------------------------
# Shell hooks — activate mise and other tools early so they are on PATH
# before subsequent conf.d files execute (e.g. zellij-autostart.fish).
# ---------------------------------------------------------------------------
meowctl shell fish | source
