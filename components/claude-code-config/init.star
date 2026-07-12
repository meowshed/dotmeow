# components/claude-code-config
#
# platform: macos
# after:    ["@stdlib//components/claude-code"]
#
# Symlinks a generic, secret-free Claude Code base config into ~/.claude:
#   settings.json  — permissions + official plugins + status line + theme.
#                    No hooks, no MCP servers — nothing personal or secret.
#   statusline.sh  — Catppuccin Mocha status line (model · dir · git branch).
#
# Per-project permission grants belong in each repo's .claude/settings.local.json
# (choose "this project" when granting), NOT here — so this base stays clean and
# reproducible and does not accumulate machine-specific allow-list entries.
#
# The enabled official plugins (rust-analyzer-lsp, lua-lsp, code-review) need
# their language servers on PATH (rust-analyzer via rustup, lua-language-server
# via brew); those come from the toolchain, not from this component.

platforms = ["macos"]
after = ["@stdlib//components/claude-code"]

def install(ctx):
    claude_dir = ctx.home + "/.claude"
    ctx.mkdir(claude_dir)
    ctx.link_file("settings.json", claude_dir + "/settings.json")
    # Claude Code execve()s the statusLine command; the extracted source loses the
    # git execute bit (files land mode 0600), so set +x before linking.
    ctx.run("chmod", ["+x", ctx.component_dir + "/statusline.sh"])
    ctx.link_file("statusline.sh", claude_dir + "/statusline.sh")
    ctx.log("claude-code-config: linked settings.json + statusline.sh")

def upgrade(ctx):
    install(ctx)

def verify(ctx):
    ok = True
    for p in [ctx.home + "/.claude/settings.json", ctx.home + "/.claude/statusline.sh"]:
        if not ctx.file_exists(p):
            ctx.log("claude-code-config: MISSING " + p)
            ok = False
    if ok:
        ctx.log("claude-code-config: OK")

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.claude/settings.json")
    ctx.remove_symlink(ctx.home + "/.claude/statusline.sh")
    ctx.log("claude-code-config: removed")
