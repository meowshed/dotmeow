# components/starship-config.star
#
# platform: all
# after:    ["@stdlib//components/starship"]
#
# Links starship.toml into ~/.config/starship.toml.
# Emits starship-cockpit keyboard layout env vars via the shell hook so they
# flow through `meowctl shell fish | source` alongside all other component hooks.

after = ["@stdlib//components/starship"]

def install(ctx):
    ctx.link_file("starship.toml", ctx.home + "/.config/starship.toml")

def upgrade(ctx):
    install(ctx)

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.config/starship.toml")

def shell(ctx):
    if ctx.shell == "fish":
        ctx.emit("set -gx STARSHIP_COCKPIT_KEYBOARD_LAYOUT_ENABLED true")
        ctx.emit("set -gx STARSHIP_COCKPIT_KEYBOARD_LAYOUT_ABC \"\"")
        ctx.emit("set -gx STARSHIP_COCKPIT_KEYBOARD_LAYOUT_RUSSIAN \"RU\"")
        ctx.emit("set -gx STARSHIP_COCKPIT_KEYBOARD_LAYOUT_RUSSIANWIN \"RU\"")
