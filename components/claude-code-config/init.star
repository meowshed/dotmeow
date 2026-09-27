# components/claude-code-config
#
# platform: macos
# after:    ["@stdlib//components/claude-code"]
#
# Symlinks a secret-free Claude Code user config into ~/.claude:
#   settings.json  — permissions (allow + deny), plugins and marketplaces,
#                    skill overrides, the Notification hook, status line, theme.
#                    No MCP servers and no account values.
#   CLAUDE.md      — user-level instructions loaded into every session.
#   statusline.sh  — Catppuccin Mocha status line (model · dir · git branch).
#
# Claude Code writes settings changes through the symlink into the module
# cache, so a /config or /plugin change lands there and is lost on the next
# upgrade. Copy it back into this file to keep it.
#
# Per-project permission grants belong in each repo's .claude/settings.local.json
# (choose "this project" when granting), NOT here — so this base stays clean and
# reproducible and does not accumulate machine-specific allow-list entries.
#
# The rust-analyzer-lsp plugin needs rust-analyzer on PATH (via rustup); that
# comes from the toolchain, not from this component.
#
# Account profiles let one machine use two Claude Code accounts:
#   profiles/personal.json          the account from `claude login`.
#   profiles/aws.json               Amazon Bedrock. This component writes the
#                                   file from profiles/aws.json.tmpl.
#   conf.d/50-claude-profiles.fish  the claude-personal and claude-aws wrappers.
#
# Never put an account value in settings.json. That file is a symlink into the
# version-pinned module cache. A module upgrade replaces the cache directory and
# discards every local edit. Account values belong in ~/.claude/profiles/aws.json.
# This component writes that file once and never overwrites it.
#
# The install function prompts for the Bedrock values. The upgrade function does
# not prompt, because an absent aws.json means the user declined. To add the
# profile later, write ~/.claude/profiles/aws.json from profiles/aws.json.tmpl.
#
# Bedrock in some regions needs an inference profile id in ANTHROPIC_MODEL. Add
# that key to ~/.claude/profiles/aws.json when a run fails to resolve a model.

platforms = ["macos"]
after = ["@stdlib//components/claude-code"]

def _profiles_dir(ctx):
    return ctx.home + "/.claude/profiles"

def _aws_overlay(ctx):
    return _profiles_dir(ctx) + "/aws.json"

def _link_managed(ctx):
    claude_dir = ctx.home + "/.claude"
    ctx.mkdir(claude_dir)
    ctx.link_file("settings.json", claude_dir + "/settings.json")
    ctx.link_file("CLAUDE.md", claude_dir + "/CLAUDE.md")
    # Claude Code execve()s the statusLine command; the extracted source loses the
    # git execute bit (files land mode 0600), so set +x before linking.
    ctx.run("chmod", ["+x", ctx.component_dir + "/statusline.sh"])
    ctx.link_file("statusline.sh", claude_dir + "/statusline.sh")

    ctx.mkdir(_profiles_dir(ctx))
    ctx.link_file("profiles/personal.json", _profiles_dir(ctx) + "/personal.json")

    fish_confd = ctx.home + "/.config/fish/conf.d"
    ctx.mkdir(fish_confd)
    ctx.link_file("conf.d/50-claude-profiles.fish", fish_confd + "/50-claude-profiles.fish")

def install(ctx):
    _link_managed(ctx)
    ctx.log("claude-code-config: linked settings.json, CLAUDE.md, statusline.sh, personal profile, fish wrappers")

    if ctx.file_exists(_aws_overlay(ctx)):
        return

    ans = ctx.prompt("Add a Claude Code profile for Amazon Bedrock? (y/N)").lower().strip()
    if ans not in ["y", "yes"]:
        ctx.log("claude-code-config: Bedrock profile skipped (declined)")
        return

    region = ctx.prompt("AWS region for Bedrock").strip()
    aws_profile = ctx.prompt("AWS profile name").strip()
    content = ctx.render_file("profiles/aws.json.tmpl", {
        "AWS_REGION": region,
        "AWS_PROFILE": aws_profile,
    })
    ctx.write_file(_aws_overlay(ctx), content)
    ctx.log("claude-code-config: wrote " + _aws_overlay(ctx))

def upgrade(ctx):
    # Relink the managed files only. An upgrade must not prompt.
    _link_managed(ctx)
    ctx.log("claude-code-config: relinked managed files")

def verify(ctx):
    ok = True
    for p in [
        ctx.home + "/.claude/settings.json",
        ctx.home + "/.claude/CLAUDE.md",
        ctx.home + "/.claude/statusline.sh",
        _profiles_dir(ctx) + "/personal.json",
        ctx.home + "/.config/fish/conf.d/50-claude-profiles.fish",
    ]:
        if not ctx.file_exists(p):
            ctx.log("claude-code-config: MISSING " + p)
            ok = False
    if not ctx.file_exists(_aws_overlay(ctx)):
        ctx.log("claude-code-config: no Bedrock profile (optional)")
    if ok:
        ctx.log("claude-code-config: OK")

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.claude/settings.json")
    ctx.remove_symlink(ctx.home + "/.claude/CLAUDE.md")
    ctx.remove_symlink(ctx.home + "/.claude/statusline.sh")
    ctx.remove_symlink(_profiles_dir(ctx) + "/personal.json")
    ctx.remove_symlink(ctx.home + "/.config/fish/conf.d/50-claude-profiles.fish")
    # aws.json holds user data. This component does not remove it.
    ctx.log("claude-code-config: removed")
