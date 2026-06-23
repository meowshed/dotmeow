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

def verify(ctx):
    p = ctx.home + "/.hammerspoon/init.lua"
    if ctx.file_exists(p):
        ctx.log("hammerspoon-config: OK")
    else:
        ctx.log("hammerspoon-config: MISSING " + p)

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.hammerspoon/init.lua")
