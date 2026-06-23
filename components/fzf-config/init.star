# components/fzf-config.star
#
# platform: all
# after:    ["@stdlib//bundles/modern-shell"]
#
# Links fzf fish conf.d hook into ~/.config/fish/conf.d/.
# Emits `fzf --fish | source` via shell hook so fzf completion
# and key bindings are initialized through meowctl shell integration.
# Sets FZF_DEFAULT_OPTS (Catppuccin Mocha colors + UX layout) and
# per-binding opts (CTRL-T bat preview, ALT-C eza/tree preview).

after = ["@stdlib//bundles/modern-shell"]

def install(ctx):
    fish_confd = ctx.home + "/.config/fish/conf.d"
    ctx.mkdir(fish_confd)
    ctx.link_file("conf.d/fzf-theme.fish", fish_confd + "/fzf-theme.fish")

def upgrade(ctx):
    install(ctx)

def verify(ctx):
    p = ctx.home + "/.config/fish/conf.d/fzf-theme.fish"
    if ctx.file_exists(p):
        ctx.log("fzf-config: OK")
    else:
        ctx.log("fzf-config: MISSING " + p)

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.config/fish/conf.d/fzf-theme.fish")

def shell(ctx):
    if ctx.shell == "fish":
        ctx.emit("fzf --fish | source")
    elif ctx.shell == "bash":
        ctx.emit('eval "$(fzf --bash)"')
    elif ctx.shell == "zsh":
        ctx.emit('eval "$(fzf --zsh)"')
