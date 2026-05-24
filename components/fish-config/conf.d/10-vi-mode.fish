# ~/.config/fish/conf.d/10-vi-mode.fish
# Vi key bindings and cursor shape configuration.
# Loaded after environment, before aliases and tool hooks.

if status is-interactive
    # Enable vi mode, start in insert mode
    fish_vi_key_bindings insert

    # Cursor shapes per mode
    set -g fish_cursor_default     block
    set -g fish_cursor_insert      line
    set -g fish_cursor_replace_one underscore
    set -g fish_cursor_visual      block
end
