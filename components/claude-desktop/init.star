# components/claude-desktop/init.star
#
# platform: macos
# after:    ["@stdlib//components/brew"]
#
# Claude Desktop — Anthropic's desktop app (GUI counterpart to claude-code).
# Installed via Homebrew cask `claude`. Config/MCP is user-specific and lives
# outside version control (~/Library/Application Support/Claude/), so this
# component only installs the app.

platforms = ["macos"]
after = ["@stdlib//components/brew"]

def install(ctx):
    pkg(manager = "brew", name = "claude", cask = True)

def upgrade(ctx):
    uppkg(manager = "brew", name = "claude", cask = True)

def verify(ctx):
    if ctx.file_exists("/Applications/Claude.app"):
        ctx.log("claude-desktop: OK")
    else:
        ctx.log("claude-desktop: MISSING /Applications/Claude.app")

def uninstall(ctx):
    unpkg(manager = "brew", name = "claude", cask = True)
