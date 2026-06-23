# ~/.config/fish/conf.d/30-aliases.fish
# Shell aliases, abbreviations, and function wrappers.
#
# Convention:
#   abbr            — simple text expansion (visible in history, editable before run)
#   function --wraps — commands that replace builtins or need $argv manipulation
#
# All replacements are conditional: if the modern tool is not installed,
# the original builtin remains available.

# ---------------------------------------------------------------------------
# neovim — replace vim/vi
# ---------------------------------------------------------------------------
if command -q nvim
    function vim --wraps nvim --description 'neovim'
        command nvim $argv
    end
    function vi --wraps nvim --description 'neovim'
        command nvim $argv
    end
end

# ---------------------------------------------------------------------------
# bat — replace cat / less with syntax highlighting
# ---------------------------------------------------------------------------
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
        test (count $argv) -gt 0 || return 1
        $argv --help 2>&1 | command bat --plain --language=help
    end
end

# ---------------------------------------------------------------------------
# eza — replace ls and tree
# ---------------------------------------------------------------------------
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
    function lai --wraps eza --description 'eza -la --no-git-ignore'
        command eza -la --no-git-ignore $argv
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

# ---------------------------------------------------------------------------
# duf — replace df
# ---------------------------------------------------------------------------
if command -q duf
    function df --wraps duf --description 'disk usage via duf'
        command duf $argv
    end
end

# ---------------------------------------------------------------------------
# ripgrep — abbreviations
# ---------------------------------------------------------------------------
# Note: rgf is deliberately omitted because it conflicts with the rgfi
# autoloaded function (interactive ripgrep with fzf).  Add it in 99-local.fish
# if you prefer the simple form.
if command -q rg
    abbr --query rgh || abbr --add rgh  'rg --hidden'
    abbr --query rgi || abbr --add rgi  'rg --no-ignore'
    abbr --query rgl || abbr --add rgl  'rg --files-with-matches'
end

# ---------------------------------------------------------------------------
# git — abbreviations
# ---------------------------------------------------------------------------
# Note: gs, glog, and rgf are deliberately NOT defined as abbreviations here
# because they conflict with autoloaded functions in functions/ that provide
# richer interactive behaviour (fzf, short-branch format, etc.).
# Abbreviations expand before functions are called, so the function would be
# dead code.  Use the function names directly or add personal abbreviations
# in 99-local.fish if you prefer the simple form.
#
# Guard with --query so interactive additions in 99-local.fish are preserved.
if command -q git
    abbr --query g  || abbr --add g     git
    abbr --query gd || abbr --add gd    'git diff'
    abbr --query ga || abbr --add ga    'git add'
    abbr --query gc || abbr --add gc    'git commit'
    abbr --query gp || abbr --add gp    'git push'
    abbr --query gl || abbr --add gl    'git pull'
end
