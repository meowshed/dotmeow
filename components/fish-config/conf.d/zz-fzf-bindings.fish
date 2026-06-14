# ~/.config/fish/conf.d/zz-fzf-bindings.fish
# Runs last (zz- prefix) so it overrides fzf defaults after fzf is sourced.
# Ctrl+R stays on simple fzf/Fish history; optional fzf.fish git log lives on
# Alt+G to avoid editor and multiplexer leader chords.

if status is-interactive
    if functions -q fzf_configure_bindings
        fzf_configure_bindings \
            --history=ctrl-r \
            --variables=ctrl-v \
            --directory=ctrl-f \
            --git_log=alt-g \
            --git_status=ctrl-s \
            --processes=ctrl-p
    else if functions -q fzf-history-widget
        bind \cr fzf-history-widget
        bind -M insert \cr fzf-history-widget

        if functions -q fzf-cd-widget
            bind \cf fzf-cd-widget
            bind -M insert \cf fzf-cd-widget
        end
    end
end
