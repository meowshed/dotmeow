# components/claude-desktop-config
#
# platform: macos
# after:    ["@stdlib//components/claude-desktop", "@stdlib//components/mise"]
#
# Merges the managed Claude Desktop settings in settings.json into
# ~/Library/Application Support/Claude/claude_desktop_config.json.
#
# The file is merged, not linked, because Claude Desktop rewrites it with
# per-account and per-session state (account ids, folder grants, pane layout).
# The merge sets only the keys in settings.json and leaves the rest alone:
#   mcpServers     — each named server is replaced whole.
#   preferences    — each named key is set; other preferences are kept.
#   coworkUserFilesPath — set to ~/Claude.
#
# Claude Desktop does not inherit the shell PATH, so an MCP server's command
# must be absolute. The "uvx" command is resolved with ctx.which at apply time;
# the blender server is skipped with a log line when uvx is not on PATH.
#
# Quit Claude Desktop before `meowctl apply`: the app writes its in-memory copy
# of the file on exit and would drop the merged keys.

platforms = ["macos"]
after = ["@stdlib//components/claude-desktop", "@stdlib//components/mise"]

def _config_path(ctx):
    return ctx.home + "/Library/Application Support/Claude/claude_desktop_config.json"

def _merge(ctx):
    managed = json.decode(ctx.read_file(ctx.component_dir + "/settings.json"))
    path = _config_path(ctx)
    config = json.decode(ctx.read_file(path)) if ctx.file_exists(path) else {}

    servers = config.get("mcpServers", {})
    for name, server in managed["mcpServers"].items():
        if server["command"] == "uvx":
            uvx = ctx.which("uvx")
            if not uvx:
                ctx.log("claude-desktop-config: uvx not on PATH, skipped MCP server " + name)
                continue
            server["command"] = uvx
        servers[name] = server
    config["mcpServers"] = servers

    prefs = config.get("preferences", {})
    for key, value in managed["preferences"].items():
        prefs[key] = value
    config["preferences"] = prefs

    config["coworkUserFilesPath"] = ctx.home + "/Claude"

    ctx.mkdir(ctx.home + "/Library/Application Support/Claude")
    ctx.write_file(path, json.indent(json.encode(config), indent = "  ") + "\n")

def install(ctx):
    _merge(ctx)
    ctx.log("claude-desktop-config: merged managed keys into " + _config_path(ctx))

def upgrade(ctx):
    install(ctx)

def verify(ctx):
    path = _config_path(ctx)
    if not ctx.file_exists(path):
        ctx.log("claude-desktop-config: MISSING " + path)
        return
    config = json.decode(ctx.read_file(path))
    managed = json.decode(ctx.read_file(ctx.component_dir + "/settings.json"))
    ok = True
    for name in managed["mcpServers"]:
        if name not in config.get("mcpServers", {}):
            ctx.log("claude-desktop-config: MISSING MCP server " + name)
            ok = False
    prefs = config.get("preferences", {})
    for key, value in managed["preferences"].items():
        if prefs.get(key) != value:
            ctx.log("claude-desktop-config: preference " + key + " differs")
            ok = False
    if ok:
        ctx.log("claude-desktop-config: OK")

def uninstall(ctx):
    # The file holds the app's own state; removing the managed keys would
    # disconnect MCP servers the user may still want. Leave it in place.
    ctx.log("claude-desktop-config: left " + _config_path(ctx) + " in place")
