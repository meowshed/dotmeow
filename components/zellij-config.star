# components/zellij-config.star
#
# platform: all
# after:    ["@stdlib//components/zellij", "@stdlib//components/fish"]
#
# Links zellij config files from this component into ~/.config/zellij/.
# Also links zellij-tab-name.fish into ~/.config/fish/conf.d/ for
# git-aware tab naming and pin/unpin support via `zt`.

after = ["@stdlib//components/zellij", "@stdlib//components/fish"]

def _zellij_home(ctx):
    return ctx.home + "/.config/zellij"

def install(ctx):
    z = _zellij_home(ctx)
    ctx.mkdir(z)
    ctx.mkdir(z + "/layouts")
    ctx.mkdir(z + "/themes")
    ctx.link_file("config.kdl",              z + "/config.kdl")
    ctx.link_file("layouts/default.kdl",     z + "/layouts/default.kdl")
    ctx.link_file("layouts/welcome.kdl",     z + "/layouts/welcome.kdl")
    ctx.link_file("themes/catppuccin-mocha.kdl", z + "/themes/catppuccin-mocha.kdl")
    fish_confd = ctx.home + "/.config/fish/conf.d"
    ctx.mkdir(fish_confd)
    ctx.link_file("conf.d/zellij-tab-name.fish", fish_confd + "/zellij-tab-name.fish")

def upgrade(ctx):
    install(ctx)

def uninstall(ctx):
    z = _zellij_home(ctx)
    ctx.remove_symlink(z + "/config.kdl")
    ctx.remove_symlink(z + "/layouts/default.kdl")
    ctx.remove_symlink(z + "/layouts/welcome.kdl")
    ctx.remove_symlink(z + "/themes/catppuccin-mocha.kdl")
    ctx.remove_symlink(ctx.home + "/.config/fish/conf.d/zellij-tab-name.fish")
