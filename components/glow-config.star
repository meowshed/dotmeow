# components/glow-config.star
#
# platform: all
# after:    ["@stdlib//bundles/modern-macos"]
#
# Links glow config into ~/.config/glow/glow.yml.

after = ["@stdlib//bundles/modern-macos"]

def install(ctx):
    d = ctx.home + "/.config/glow"
    ctx.mkdir(d)
    ctx.link_file("glow.yml", d + "/glow.yml")

def upgrade(ctx):
    install(ctx)

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.config/glow/glow.yml")
