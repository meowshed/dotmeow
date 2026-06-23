# ~/.config/fish/conf.d/fzf-theme.fish
# fzf — Catppuccin Mocha theme + UX defaults
#
# FZF_DEFAULT_OPTS sets colors and layout flags applied to every fzf call.
# Per-binding opts (FZF_CTRL_T_OPTS, FZF_ALT_C_OPTS)
# layer additional behavior on top without polluting the global opts.
#
# Best practices followed:
#   - No --preview in FZF_DEFAULT_OPTS (fzf docs: "DO NOT DO THIS")
#   - No --ansi in FZF_DEFAULT_OPTS (slows initial scan)
#   - bat used for file preview in CTRL-T (requires bat in PATH)
#   - tree used for directory preview in ALT-C (requires eza/tree)
#
# Note: fzf completion and key bindings are initialized via the shell hook
# emitted by fzf-config/init.star (`fzf --fish | source`), not here.

if command -q fzf
    # Use fd as the default file lister: faster, .gitignore-aware, hidden-file-aware.
    if command -q fd
        set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --exclude .git"
    end

    set -gx FZF_DEFAULT_OPTS "\
--color=bg:#1e1e2e,fg:#cdd6f4 \
--color=bg+:#313244,fg+:#cdd6f4 \
--color=selected-bg:#45475a \
--color=hl:#f38ba8,hl+:#f38ba8 \
--color=header:#f38ba8 \
--color=info:#cba6f7,prompt:#cba6f7 \
--color=pointer:#f5e0dc,spinner:#f5e0dc \
--color=marker:#b4befe \
--color=border:#6c7086,label:#cdd6f4 \
--layout=reverse \
--height=40% \
--border=rounded \
--cycle \
--bind=ctrl-z:ignore"

    # CTRL-T: paste selected files/dirs onto the command line
    # Preview with bat; skip .git and node_modules
    if command -q bat
        set -gx FZF_CTRL_T_OPTS "\
--walker-skip .git,node_modules,target,.cache \
--preview 'bat -n --color=always --line-range :200 {}' \
--bind 'ctrl-/:change-preview-window(down|hidden|)'"
    else
        set -gx FZF_CTRL_T_OPTS "\
--walker-skip .git,node_modules,target,.cache"
    end

    # ALT-C: cd into selected directory; tree preview via eza or tree
    if command -q eza
        set -gx FZF_ALT_C_OPTS "\
--walker-skip .git,node_modules,target,.cache \
--preview 'eza --tree --level=2 --color=always {}'"
    else if command -q tree
        set -gx FZF_ALT_C_OPTS "\
--walker-skip .git,node_modules,target,.cache \
--preview 'tree -C {} | head -100'"
    end
end
