# components/fzf-config.star
#
# platform: all
# after:    ["@stdlib//bundles/modern-shell"]
#
# Links fzf fish conf.d hook into ~/.config/fish/conf.d/.
# Sets FZF_DEFAULT_OPTS (Catppuccin Mocha colors + UX layout) and
# per-binding opts (CTRL-T bat preview, ALT-C eza/tree preview, CTRL-R clipboard).

after = ["@stdlib//bundles/modern-shell"]

def install(ctx):
    fish_confd = ctx.home + "/.config/fish/conf.d"
    ctx.mkdir(fish_confd)
    ctx.link_file("conf.d/fzf-theme.fish", fish_confd + "/fzf-theme.fish")

def upgrade(ctx):
    install(ctx)

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.config/fish/conf.d/fzf-theme.fish")
