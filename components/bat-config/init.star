# components/bat-config.star
#
# platform: all
# after:    ["@stdlib//bundles/modern-shell"]
#
# Links bat config into ~/.config/bat/config.
# Sets BAT_CONFIG_PATH so bat finds the config regardless of version.

after = ["@stdlib//bundles/modern-shell"]

def install(ctx):
    d = ctx.home + "/.config/bat"
    ctx.mkdir(d)
    ctx.link_file("config", d + "/config")

def upgrade(ctx):
    install(ctx)

def verify(ctx):
    p = ctx.home + "/.config/bat/config"
    if ctx.file_exists(p):
        ctx.log("bat-config: OK")
    else:
        ctx.log("bat-config: MISSING " + p)

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.config/bat/config")

def shell(ctx):
    if ctx.shell == "fish":
        ctx.emit("set -gx BAT_CONFIG_PATH ~/.config/bat/config")
    elif ctx.shell in ("bash", "zsh", "posix"):
        ctx.emit("export BAT_CONFIG_PATH=~/.config/bat/config")
