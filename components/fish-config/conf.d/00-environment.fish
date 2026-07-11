# ~/.config/fish/conf.d/00-environment.fish
# Core environment variables and PATH setup.
# Loaded before all other conf.d files.

# ---------------------------------------------------------------------------
# Locale
# ---------------------------------------------------------------------------
set -gx LC_ALL en_US.UTF-8

# ---------------------------------------------------------------------------
# XDG base directories — set explicitly so tools use consistent paths
# ---------------------------------------------------------------------------
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME   $HOME/.local/share
set -gx XDG_CACHE_HOME  $HOME/.cache

# ---------------------------------------------------------------------------
# PATH — user-local binaries first
# ---------------------------------------------------------------------------
if test -d $HOME/.local/bin
    fish_add_path $HOME/.local/bin
end

# ---------------------------------------------------------------------------
# Homebrew
# ---------------------------------------------------------------------------
set -gx HOMEBREW_NO_ANALYTICS  1
set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx HOMEBREW_NO_ENV_HINTS  1

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

# less flags: ANSI passthrough, quit-if-one-screen, mouse scroll
set -gx LESS "-RF --mouse"

# ---------------------------------------------------------------------------
# Disable greeting
# ---------------------------------------------------------------------------
set -g fish_greeting

# ---------------------------------------------------------------------------
# Shell hooks — activate mise and other tools early so they are on PATH
# before subsequent conf.d files execute.
#
# `meowctl hook shell` picks the target shell from $SHELL, not from the fish
# we are running in. In panes spawned by tmux-resurrect (and other non-login
# contexts) $SHELL can be stale — a previous login shell, or empty — which
# makes the hook emit zsh/bash syntax that silently fails to `source` in fish,
# so starship/zoxide/direnv never initialise. Pin $SHELL to the running fish
# first so the hook always emits fish.
# ---------------------------------------------------------------------------
set -gx SHELL (status fish-path)
meowctl shell fish | source
