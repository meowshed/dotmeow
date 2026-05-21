# components/eza-config.star
#
# platform: all
# after:    ["@stdlib//bundles/modern-shell"]
#
# Links eza config and theme into ~/.config/eza/.
# Sets EZA_CONFIG_DIR so eza finds both config and theme.yml.

after = ["@stdlib//bundles/modern-shell"]

def install(ctx):
    d = ctx.home + "/.config/eza"
    ctx.mkdir(d)
    ctx.link_file("config",    d + "/config")
    ctx.link_file("theme.yml", d + "/theme.yml")

def upgrade(ctx):
    install(ctx)

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.config/eza/config")
    ctx.remove_symlink(ctx.home + "/.config/eza/theme.yml")

def shell(ctx):
    if ctx.shell == "fish":
        ctx.emit("set -gx EZA_CONFIG_DIR ~/.config/eza")
    elif ctx.shell in ("bash", "zsh", "posix"):
        ctx.emit("export EZA_CONFIG_DIR=~/.config/eza")
