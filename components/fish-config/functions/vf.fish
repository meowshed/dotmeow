function vf --description 'Fuzzy-find and open file(s) in nvim'
    set -l files
    if command -q fd
        set files (fd --type f --hidden --exclude .git $argv | fzf --multi --preview 'bat --color=always --line-range :200 {}')
    else
        set files (find . -type f -not -path '*/\.git/*' $argv | fzf --multi --preview 'head -100 {}')
    end
    if test -n "$files"
        nvim $files
    end
end
