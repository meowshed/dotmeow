# components/capslock-control/init.star
#
# platforms: ["macos"]
#
# Optional Caps Lock -> Left Control remap via hidutil, persisted through a
# LaunchAgent (RunAtLoad). Plain swap only — no tap-for-Escape; that needs
# Karabiner-Elements (@stdlib//components/karabiner_elements).
#
# Prompts on install; declining installs nothing and `upgrade` will not
# re-prompt on later applies (absence of the plist is treated as "declined").

platforms = ["macos"]

def _dest(ctx):
    return ctx.home + "/Library/LaunchAgents/org.dotmeow.capslock-control.plist"

def install(ctx):
    ans = ctx.prompt("Remap Caps Lock to Left Control? (y/N)").lower().strip()
    if ans not in ["y", "yes"]:
        ctx.log("capslock-control: skipped (declined)")
        return

    d = ctx.home + "/Library/LaunchAgents"
    ctx.mkdir(d)
    dest = _dest(ctx)
    ctx.link_file("org.dotmeow.capslock-control.plist", dest)
    ctx.run("launchctl", ["load", dest])
    ctx.log("capslock-control: loaded LaunchAgent")

def upgrade(ctx):
    dest = _dest(ctx)
    if not ctx.file_exists(dest):
        # Declined at install time; don't nag on every apply.
        return
    ctx.run("launchctl", ["unload", dest])
    d = ctx.home + "/Library/LaunchAgents"
    ctx.mkdir(d)
    ctx.link_file("org.dotmeow.capslock-control.plist", dest)
    ctx.run("launchctl", ["load", dest])
    ctx.log("capslock-control: reloaded LaunchAgent")

def verify(ctx):
    dest = _dest(ctx)
    if not ctx.file_exists(dest):
        ctx.log("capslock-control: not installed (declined)")
        return
    r = ctx.run("launchctl", ["list"])
    if "org.dotmeow.capslock-control" in r.stdout:
        ctx.log("capslock-control: OK")
    else:
        ctx.log("capslock-control: MISSING")

def uninstall(ctx):
    dest = _dest(ctx)
    if ctx.file_exists(dest):
        ctx.run("launchctl", ["unload", dest])
        ctx.run("rm", ["-f", dest])
        ctx.log("capslock-control: removed LaunchAgent")
