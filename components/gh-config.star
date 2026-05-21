# components/gh-config.star
#
# platform: all
# after:    ["@stdlib//components/gh"]
#
# Links gh config into ~/.config/gh/config.yml.
# hosts.yml is managed by `gh auth login` — not touched.

after = ["@stdlib//components/gh"]

def install(ctx):
    d = ctx.home + "/.config/gh"
    ctx.mkdir(d)
    ctx.link_file("config.yml", d + "/config.yml")

def upgrade(ctx):
    install(ctx)

def uninstall(ctx):
    ctx.unlink_file(ctx.home + "/.config/gh/config.yml")
