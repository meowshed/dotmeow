# components/fonts.star
#
# platform: macos
# after:    ["@stdlib//components/brew"]
#
# Nerd Fonts and additional programming fonts.
# Installed via Homebrew cask (font formulae).

platforms = ["macos"]
after = ["@stdlib//components/brew"]

_FONTS = [
    "font-hack-nerd-font",
    "font-caskaydia-cove-nerd-font",
    "font-caskaydia-mono-nerd-font",
    "font-fira-code-nerd-font",
    "font-fira-sans",
    "font-inconsolata-nerd-font",
    "font-jetbrains-mono",
    "font-jetbrains-mono-nerd-font",
]

def install(ctx):
    for font in _FONTS:
        pkg(manager = "brew", name = font, cask = True)

def verify(ctx):
    for font in _FONTS:
        ctx.run("brew", ["list", "--cask", font])

def upgrade(ctx):
    for font in _FONTS:
        uppkg(manager = "brew", name = font, cask = True)

def uninstall(ctx):
    for font in _FONTS:
        unpkg(manager = "brew", name = font, cask = True)
