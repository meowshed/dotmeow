# components/hammerspoon-config.star
#
# platform: macos
# Links ~/.hammerspoon/init.lua from this repo.
# Hammerspoon must be installed and granted Accessibility permissions manually.

platforms = ["macos"]
after = ["@stdlib//components/hammerspoon"]

def install(ctx):
    ctx.mkdir(ctx.home + "/.hammerspoon")
    ctx.link_file("init.lua", ctx.home + "/.hammerspoon/init.lua")

def upgrade(ctx):
    ctx.link_file("init.lua", ctx.home + "/.hammerspoon/init.lua")

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.hammerspoon/init.lua")
