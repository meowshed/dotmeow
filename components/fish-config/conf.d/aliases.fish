# ~/.config/fish/conf.d/aliases.fish
# Shell aliases and abbreviations.
#
# Convention:
#   abbr  — simple text expansion (visible in history, easy to edit before run)
#   function --wraps — commands that replace builtins or need $argv manipulation

# ----------------------------------------------------------------------------
# duf — better df
# ----------------------------------------------------------------------------
if command -q duf
    function df --wraps duf --description 'disk usage via duf'
        command duf $argv
    end
end

# ----------------------------------------------------------------------------
# neovim
# ----------------------------------------------------------------------------
if command -q nvim
    function vim --wraps nvim --description 'neovim'
        command nvim $argv
    end
    function vi --wraps nvim --description 'neovim'
        command nvim $argv
    end
end

# ----------------------------------------------------------------------------
# bat — better cat/less
# ----------------------------------------------------------------------------
if command -q bat
    function cat --wraps bat --description 'bat (cat with syntax highlighting)'
        command bat --paging=never $argv
    end
    function less --wraps bat --description 'bat (paged)'
        command bat --paging=always $argv
    end
    function bathelp --description 'bat help renderer'
        command bat --plain --language=help $argv
    end
    function help --description 'show command --help via bat'
        $argv --help 2>&1 | command bat --plain --language=help
    end
end

# ----------------------------------------------------------------------------
# ripgrep
# ----------------------------------------------------------------------------
if command -q rg
    abbr --add rgh  'rg --hidden'
    abbr --add rgi  'rg --no-ignore'
    abbr --add rgf  'rg --files'
    abbr --add rgl  'rg --files-with-matches'
end

# ----------------------------------------------------------------------------
# eza — better ls
# ----------------------------------------------------------------------------
if command -q eza
    function ls --wraps eza --description 'eza'
        command eza $argv
    end
    function l --wraps eza --description 'eza -l'
        command eza -l $argv
    end
    function la --wraps eza --description 'eza -la'
        command eza -la $argv
    end
    function ll --wraps eza --description 'eza -l --git'
        command eza -l --git $argv
    end
    function tree --wraps eza --description 'eza --tree'
        command eza --tree $argv
    end
    function lt --wraps eza --description 'eza --tree --level=2'
        command eza --tree --level=2 $argv
    end
    function lta --wraps eza --description 'eza --tree --level=2 -a'
        command eza --tree --level=2 -a $argv
    end
end

# ----------------------------------------------------------------------------
# git abbreviations
# abbr preferred over alias: expands visibly, records full command in history
# ----------------------------------------------------------------------------
if command -q git
    abbr --add g     git
    abbr --add gs    'git status'
    abbr --add gd    'git diff'
    abbr --add ga    'git add'
    abbr --add gc    'git commit'
    abbr --add gp    'git push'
    abbr --add gl    'git pull'
    abbr --add glog  'git log --oneline --graph --decorate'
end
