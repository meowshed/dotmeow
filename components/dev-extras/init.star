# components/dev-extras.star
#
# platform: macos
# after:    ["@stdlib//components/brew"]
#
# Small standalone dev utilities not covered by stdlib bundles.

platforms = ["macos"]
after = ["@stdlib//components/brew"]

def install(ctx):
    pkg(manager = "brew", name = "watch")

def verify(ctx):
    ctx.run("watch", ["--version"])

def upgrade(ctx):
    uppkg(manager = "brew", name = "watch")

def uninstall(ctx):
    unpkg(manager = "brew", name = "watch")
