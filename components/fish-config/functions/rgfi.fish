function rgfi --description 'Interactive ripgrep with fzf preview'
    if not command -q rg; or not command -q fzf
        echo 'rg and fzf are required'
        return 1
    end

    set -l query (commandline -t)
    if test -z "$query"
        set query $argv[1]
    end
    test -z "$query" && return 0

    set -l result (rg --color=always --line-number --no-heading $query | fzf --ansi \
        --delimiter ':' \
        --preview 'bat --color=always --highlight-line {2} --line-range (({2}-5)):+60 {1}' \
        --preview-window 'up:60%:wrap')

    if test -n "$result"
        # -m 2 limits splits so filenames containing ':' are handled correctly.
        set -l parts (string split -m 2 ':' $result)
        nvim +$parts[2] $parts[1]
    end
end
