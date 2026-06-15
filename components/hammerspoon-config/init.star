# components/hammerspoon-config.star
#
# Links ~/.hammerspoon/init.lua from this repo.
# Hammerspoon must be installed and granted Accessibility permissions manually.

after = ["@stdlib//components/hammerspoon", "@zjstatus-widgets"]

def install(ctx):
    ctx.mkdir("~/.hammerspoon")
    ctx.link_file("init.lua", "~/.hammerspoon/init.lua")

def upgrade(ctx):
    ctx.link_file("init.lua", "~/.hammerspoon/init.lua")

def uninstall(ctx):
    ctx.unlink_file("~/.hammerspoon/init.lua")
