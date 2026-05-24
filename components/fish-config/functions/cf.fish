function cf --description 'Fuzzy-find and cd into a directory'
    set -l dir
    if command -q fd
        set dir (fd --type d --hidden --exclude .git $argv | fzf --preview 'eza --tree --level=2 --color=always {}')
    else
        set dir (find . -type d -not -path '*/\.git/*' $argv | fzf --preview 'ls -la {}')
    end
    if test -n "$dir"
        cd $dir
    end
end
