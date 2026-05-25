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
    ctx.mkdir(d + "/themes")
    ctx.link_file("config", d + "/config")
    ctx.link_file("themes/catppuccin-mocha", d + "/themes/catppuccin-mocha")

def upgrade(ctx):
    install(ctx)

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.config/ghostty/config")
    ctx.remove_symlink(ctx.home + "/.config/ghostty/themes/catppuccin-mocha")
