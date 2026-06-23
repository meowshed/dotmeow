# components/tmux-config.star
#
# platform: macos
# after:    ["@stdlib//components/tmux", "@stdlib//components/sesh", "@stdlib//components/fish"]
#
# Links tmux configuration and status bar scripts into their canonical locations.
# Scripts are committed as executable (chmod +x in repo); no chmod needed at link time.
#
# Generates ~/.config/tmux/local.conf with the fish shell path at install time
# so tmux.conf does not need to hardcode /opt/homebrew/bin/fish.
#
# Installs a launchd user agent (me.retran.tmux-event-refresh) that:
#   - Watches ~/Library/Preferences/com.apple.HIToolbox.plist (keyboard layout)
#   - Watches ~/Library/DoNotDisturb/DB/Assertions.json        (focus mode)
#   - Watches /Library/Preferences/SystemConfiguration         (legacy VPN / network)
#   - Polls every 30 s via StartInterval                       (Network Extension VPNs:
#                                                               Tailscale, WireGuard, etc.)
# On any trigger it runs tmux-event-push.sh which updates tmux options instantly.
#
# TPM bootstrap (one-time, run after first meowctl apply):
#   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
#   Then launch tmux and press prefix + I

platforms = ["macos"]
after = ["@stdlib//components/tmux", "@stdlib//components/sesh", "@stdlib//components/fish"]

_SCRIPTS = [
    "tmux-keyboard.sh",
    "tmux-vpn.sh",
    "tmux-focus.sh",
    "tmux-cpu.sh",
    "tmux-memory.sh",
    "tmux-battery.sh",
    "tmux-date.sh",
    "tmux-time.sh",
    "tmux-keyboard-push.sh",
    "tmux-focus-push.sh",
    "tmux-vpn-push.sh",
    "tmux-event-push.sh",
]

_PLIST_LABEL = "me.retran.tmux-event-refresh"

def _tmux_scripts(ctx):
    return ctx.home + "/.config/tmux/scripts"

def _plist_path(ctx):
    return ctx.home + "/Library/LaunchAgents/" + _PLIST_LABEL + ".plist"

def _write_local_conf(ctx):
    r = ctx.run("which", ["fish"])
    fish_path = r.stdout.strip()
    if fish_path:
        local_conf = ctx.home + "/.config/tmux/local.conf"
        ctx.write_file(local_conf, "set -g default-shell " + fish_path + "\n")
        ctx.log("tmux-config: wrote local.conf with default-shell=" + fish_path)
    else:
        ctx.log("tmux-config: fish not found — local.conf not written; tmux will use default shell")

def _install_event_agent(ctx):
    push_script = ctx.home + "/.config/tmux/scripts/tmux-event-push.sh"
    plist = (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"'
        ' "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
        '<plist version="1.0">\n'
        '<dict>\n'
        '    <key>Label</key>\n'
        '    <string>' + _PLIST_LABEL + '</string>\n'
        '    <key>WatchPaths</key>\n'
        '    <array>\n'
        '        <string>' + ctx.home + '/Library/Preferences/com.apple.HIToolbox.plist</string>\n'
        '        <string>' + ctx.home + '/Library/DoNotDisturb/DB/Assertions.json</string>\n'
        '        <string>/Library/Preferences/SystemConfiguration</string>\n'
        '    </array>\n'
        '    <key>StartInterval</key>\n'
        '    <integer>30</integer>\n'
        '    <key>ProgramArguments</key>\n'
        '    <array>\n'
        '        <string>/bin/bash</string>\n'
        '        <string>' + push_script + '</string>\n'
        '    </array>\n'
        '    <key>RunAtLoad</key>\n'
        '    <false/>\n'
        '</dict>\n'
        '</plist>\n'
    )
    ctx.mkdir(ctx.home + "/Library/LaunchAgents")
    pp = _plist_path(ctx)
    uid = ctx.run("id", ["-u"]).stdout.strip()
    ctx.run("sh", ["-c",
        "launchctl bootout gui/" + uid + "/" + _PLIST_LABEL + " 2>/dev/null || true",
    ])
    ctx.write_file(pp, plist)
    ctx.run("sh", ["-c",
        "launchctl bootstrap gui/" + uid + " " + pp,
    ])
    ctx.log("tmux-config: loaded launchd event agent " + _PLIST_LABEL)

def _remove_event_agent(ctx):
    pp = _plist_path(ctx)
    if ctx.file_exists(pp):
        uid = ctx.run("id", ["-u"]).stdout.strip()
        ctx.run("sh", ["-c",
            "launchctl bootout gui/" + uid + " " + pp + " 2>/dev/null || true",
        ])
        ctx.run("rm", ["-f", pp])
        ctx.log("tmux-config: removed launchd event agent " + _PLIST_LABEL)

def install(ctx):
    tpm_path = ctx.home + "/.tmux/plugins/tpm"
    if not ctx.file_exists(tpm_path):
        ctx.git_clone("https://github.com/tmux-plugins/tpm", tpm_path)
        ctx.log("tmux-config: cloned TPM — launch tmux and press prefix + I to install plugins")

    ctx.link_file("tmux.conf", ctx.home + "/.tmux.conf")

    fish_confd = ctx.home + "/.config/fish/conf.d"
    ctx.mkdir(fish_confd)
    ctx.link_file("conf.d/tmux-autostart.fish", fish_confd + "/tmux-autostart.fish")

    scripts = _tmux_scripts(ctx)
    ctx.mkdir(ctx.home + "/.config/tmux")
    ctx.mkdir(scripts)
    for script in _SCRIPTS:
        ctx.link_file("scripts/" + script, scripts + "/" + script)

    _write_local_conf(ctx)
    _install_event_agent(ctx)
    ctx.log("tmux-config: linked tmux configuration")

def upgrade(ctx):
    install(ctx)
    tpm_path = ctx.home + "/.tmux/plugins/tpm"
    if ctx.file_exists(tpm_path):
        ctx.run("git", ["-C", tpm_path, "pull", "--ff-only"])
        ctx.log("tmux-config: updated TPM")

def verify(ctx):
    ok = True
    for path in [ctx.home + "/.tmux.conf", ctx.home + "/.config/tmux/local.conf"]:
        if not ctx.file_exists(path):
            ctx.log("tmux-config: MISSING " + path)
            ok = False
    for script in _SCRIPTS:
        p = _tmux_scripts(ctx) + "/" + script
        if not ctx.file_exists(p):
            ctx.log("tmux-config: MISSING " + p)
            ok = False
    if not ctx.file_exists(_plist_path(ctx)):
        ctx.log("tmux-config: MISSING launchd agent " + _PLIST_LABEL)
        ok = False
    if ok:
        ctx.log("tmux-config: OK")

def uninstall(ctx):
    _remove_event_agent(ctx)
    ctx.remove_symlink(ctx.home + "/.tmux.conf")
    ctx.remove_symlink(ctx.home + "/.config/fish/conf.d/tmux-autostart.fish")
    scripts = _tmux_scripts(ctx)
    for script in _SCRIPTS:
        ctx.remove_symlink(scripts + "/" + script)
    ctx.rmdir(scripts)
    ctx.rmdir(ctx.home + "/.config/tmux")
    ctx.log("tmux-config: removed tmux configuration")
