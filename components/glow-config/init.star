# components/glow-config.star
#
# platform: all
# after:    ["@stdlib//bundles/modern-macos"]
#
# Links glow config into ~/.config/glow/glow.yml and downloads the
# Catppuccin Mocha glamour style on first install.

after = ["@stdlib//bundles/modern-macos"]

_STYLE_URL = "https://raw.githubusercontent.com/catppuccin/glow/main/themes/catppuccin-mocha.json"

def _ensure_style(ctx):
    d = ctx.home + "/.config/glow"
    style = d + "/catppuccin-mocha.json"
    if not ctx.file_exists(style):
        ctx.run("curl", ["-fsSL", "-o", style, _STYLE_URL])
        ctx.log("glow-config: downloaded Catppuccin Mocha style")

def install(ctx):
    d = ctx.home + "/.config/glow"
    ctx.mkdir(d)
    ctx.link_file("glow.yml", d + "/glow.yml")
    _ensure_style(ctx)

def upgrade(ctx):
    install(ctx)

def verify(ctx):
    d = ctx.home + "/.config/glow"
    ok = True
    for path in [d + "/glow.yml", d + "/catppuccin-mocha.json"]:
        if not ctx.file_exists(path):
            ctx.log("glow-config: MISSING " + path)
            ok = False
    if ok:
        ctx.log("glow-config: OK")

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.config/glow/glow.yml")
    ctx.run("rm", ["-f", ctx.home + "/.config/glow/catppuccin-mocha.json"])
