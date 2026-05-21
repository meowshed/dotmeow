# components/fish-config.star
#
# platform: all
# after:    ["@stdlib//components/fish"]
#
# Links config.fish and conf.d hooks from this component into ~/.config/fish/.
#   aliases.fish — shell aliases (function --wraps) and abbreviations (abbr)

after = ["@stdlib//components/fish"]

def install(ctx):
    fish = ctx.home + "/.config/fish"
    ctx.mkdir(fish)
    ctx.mkdir(fish + "/conf.d")
    ctx.link_file("config.fish", fish + "/config.fish")
    ctx.link_file("conf.d/aliases.fish", fish + "/conf.d/aliases.fish")
    ctx.log("fish-config: linked config.fish and aliases.fish")

def upgrade(ctx):
    install(ctx)

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.config/fish/config.fish")
    ctx.remove_symlink(ctx.home + "/.config/fish/conf.d/aliases.fish")
    ctx.log("fish-config: removed symlinks")
