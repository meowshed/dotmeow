# components/karabiner-config.star
#
# platform: macos
# after:    ["@stdlib//components/karabiner_elements"]
#
# Links karabiner.json into ~/.config/karabiner/karabiner.json.
# Caps Lock → Left Control on all keyboards.

platforms = ["macos"]
after = ["@stdlib//components/karabiner_elements"]

def install(ctx):
    d = ctx.home + "/.config/karabiner"
    ctx.mkdir(d)
    ctx.link_file("karabiner.json", d + "/karabiner.json")

def upgrade(ctx):
    install(ctx)

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.config/karabiner/karabiner.json")
