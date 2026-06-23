# components/lazygit-config.star
#
# platform: all
# after:    ["@stdlib//bundles/github"]
#
# Links lazygit config into ~/.config/lazygit/config.yml.

after = ["@stdlib//bundles/github"]

def install(ctx):
    d = ctx.home + "/.config/lazygit"
    ctx.mkdir(d)
    ctx.link_file("config.yml", d + "/config.yml")

def upgrade(ctx):
    install(ctx)

def verify(ctx):
    p = ctx.home + "/.config/lazygit/config.yml"
    if ctx.file_exists(p):
        ctx.log("lazygit-config: OK")
    else:
        ctx.log("lazygit-config: MISSING " + p)

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.config/lazygit/config.yml")
