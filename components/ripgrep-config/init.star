# components/ripgrep-config.star
#
# platform: all
# after:    ["@stdlib//bundles/modern-shell"]
#
# Links ripgrep config into ~/.config/ripgrep/config.
# Sets RIPGREP_CONFIG_PATH so ripgrep finds it (XDG path, not ~/.ripgreprc).

after = ["@stdlib//bundles/modern-shell"]

def install(ctx):
    d = ctx.home + "/.config/ripgrep"
    ctx.mkdir(d)
    ctx.link_file("config", d + "/config")

def upgrade(ctx):
    install(ctx)

def verify(ctx):
    p = ctx.home + "/.config/ripgrep/config"
    if ctx.file_exists(p):
        ctx.log("ripgrep-config: OK")
    else:
        ctx.log("ripgrep-config: MISSING " + p)

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.config/ripgrep/config")

def shell(ctx):
    if ctx.shell == "fish":
        ctx.emit("set -gx RIPGREP_CONFIG_PATH ~/.config/ripgrep/config")
    elif ctx.shell in ("bash", "zsh", "posix"):
        ctx.emit("export RIPGREP_CONFIG_PATH=~/.config/ripgrep/config")
