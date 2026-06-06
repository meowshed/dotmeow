# components/ghostty-config.star
#
# platform: macos
# after:    ["@stdlib//bundles/modern-macos"]
#
# Links ghostty config into ~/.config/ghostty/config.

after = ["@stdlib//bundles/modern-macos"]

def install(ctx):
    d = ctx.home + "/.config/ghostty"
    ctx.mkdir(d)
    ctx.link_file("config", d + "/config")

def upgrade(ctx):
    install(ctx)

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.config/ghostty/config")
