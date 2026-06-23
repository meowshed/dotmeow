# components/starship-config.star
#
# platform: all
# after:    ["@stdlib//components/starship"]
#
# Links starship.toml into ~/.config/starship.toml.

after = ["@stdlib//components/starship"]

def install(ctx):
    ctx.link_file("starship.toml", ctx.home + "/.config/starship.toml")

def upgrade(ctx):
    install(ctx)

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.config/starship.toml")
