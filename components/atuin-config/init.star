# components/atuin-config.star
#
# platform: all
# after:    ["@stdlib//components/atuin"]
#
# Links atuin config into ~/.config/atuin/config.toml.
# Catppuccin Mocha theme, inline mode, sync disabled.

after = ["@stdlib//components/atuin"]

def install(ctx):
    d = ctx.home + "/.config/atuin"
    ctx.mkdir(d)
    ctx.link_file("config.toml", d + "/config.toml")

def upgrade(ctx):
    install(ctx)

def uninstall(ctx):
    ctx.unlink_file(ctx.home + "/.config/atuin/config.toml")
