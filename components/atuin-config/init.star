# components/atuin-config.star
#
# platform: all
# after:    ["@stdlib//components/atuin"]
#
# Links atuin config into ~/.config/atuin/config.toml.
# Emits `atuin init fish | source` via shell hook so Atuin
# history search (Ctrl+R, up-arrow) is initialized through
# meowctl shell integration.
# Catppuccin Mocha theme, inline mode, sync disabled.

after = ["@stdlib//components/atuin"]

def install(ctx):
    d = ctx.home + "/.config/atuin"
    ctx.mkdir(d)
    ctx.link_file("config.toml", d + "/config.toml")

def upgrade(ctx):
    install(ctx)

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.config/atuin/config.toml")

def shell(ctx):
    if ctx.shell == "fish":
        ctx.emit("atuin init fish | source")
    elif ctx.shell == "bash":
        ctx.emit('eval "$(atuin init bash)"')
    elif ctx.shell == "zsh":
        ctx.emit('eval "$(atuin init zsh)"')
