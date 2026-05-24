# ~/.config/fish/conf.d/zz-fzf-bindings.fish
# Runs last (zz- prefix) so it overrides the defaults set by fzf.fish.
# Atuin owns Ctrl+R — pass --history= (empty) to leave it unbound by fzf.
# All other bindings are explicit to avoid surprises.

if status is-interactive
    if functions -q fzf_configure_bindings
        fzf_configure_bindings \
            --history= \
            --variables=ctrl-v \
            --directory=ctrl-f \
            --git_log=ctrl-g \
            --git_status=ctrl-s \
            --processes=ctrl-p
    end
end
