# components/btop-config.star
#
# platform: all
# after:    ["@stdlib//bundles/modern-macos"]
#
# Links btop config and Catppuccin Mocha theme into ~/.config/btop/.

after = ["@stdlib//bundles/modern-macos"]

def install(ctx):
    d = ctx.home + "/.config/btop"
    ctx.mkdir(d)
    ctx.mkdir(d + "/themes")
    ctx.link_file("btop.conf",                d + "/btop.conf")
    ctx.link_file("catppuccin-mocha.theme",   d + "/themes/catppuccin-mocha.theme")

def upgrade(ctx):
    install(ctx)

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.config/btop/btop.conf")
    ctx.remove_symlink(ctx.home + "/.config/btop/themes/catppuccin-mocha.theme")
