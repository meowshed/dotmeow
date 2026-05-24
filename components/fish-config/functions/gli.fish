function gli --description 'Interactive git log with fzf preview'
    if not command -q fzf
        echo 'fzf is required'
        return 1
    end

    set -l result (git log --oneline --color=always --decorate | fzf --ansi \
        --preview 'git show --color=always {1}' \
        --preview-window 'right:60%:wrap')

    if test -n "$result"
        set -l hash (string split ' ' $result)[1]
        git show $hash
    end
end
