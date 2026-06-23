# components/tealdeer-config.star
#
# platform: all
# after:    ["@stdlib//bundles/modern-shell"]
#
# Links tealdeer config into ~/.config/tealdeer/config.toml.
# Catppuccin Mocha syntax highlighting; macOS platform search order;
# auto-update enabled (30-day interval).

after = ["@stdlib//bundles/modern-shell"]

def install(ctx):
    d = ctx.home + "/.config/tealdeer"
    ctx.mkdir(d)
    ctx.link_file("config.toml", d + "/config.toml")

def upgrade(ctx):
    install(ctx)

def verify(ctx):
    p = ctx.home + "/.config/tealdeer/config.toml"
    if ctx.file_exists(p):
        ctx.log("tealdeer-config: OK")
    else:
        ctx.log("tealdeer-config: MISSING " + p)

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.config/tealdeer/config.toml")
