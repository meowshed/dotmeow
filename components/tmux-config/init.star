# components/tmux-config.star
#
# platform: macos
# after:    ["@stdlib//components/tmux", "@stdlib//components/sesh", "@stdlib//components/fish",
#            "@stdlib//components/brew", "@stdlib//components/python"]
#
# Links tmux configuration and status bar scripts into their canonical locations.
# Scripts are committed as executable (chmod +x in repo); no chmod needed at link time.
#
# Generates ~/.config/tmux/local.conf with the fish shell path at install time
# so tmux.conf does not need to hardcode /opt/homebrew/bin/fish.
#
# All status-bar widgets are polled every status-interval second (no launchd agent).
# post-tpm.conf is linked and sourced by tmux.conf after TPM loads to override
# catppuccin window-status formats.
#
# Dependencies:
#   - osx-cpu-temp  (brew)  — CPU temperature widget (Intel only; silently skipped on Apple Silicon)
#   - libtmux       (pip3)  — required by ofirgall/tmux-window-name plugin
#
# TPM bootstrap (one-time, run after first meowctl apply):
#   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
#   Then launch tmux and press prefix + I

platforms = ["macos"]
after = ["@stdlib//components/tmux", "@stdlib//components/sesh", "@stdlib//components/fish",
         "@stdlib//components/brew", "@stdlib//components/python"]

_SCRIPTS = [
    "tmux-keyboard.sh",
    "tmux-vpn.sh",
    "tmux-focus.sh",
    "tmux-network.sh",
    "tmux-volume.sh",
    "tmux-cpu.sh",
    "tmux-temp.sh",
    "tmux-disk.sh",
    "tmux-memory.sh",
    "tmux-battery.sh",
    "tmux-date.sh",
    "tmux-time.sh",
    "tmux-keyboard-push.sh",
    "tmux-focus-push.sh",
    "tmux-vpn-push.sh",
    "tmux-event-push.sh",
    "tmux-session-picker.sh",
    "tmux-sesh-last.sh",
]

def _tmux_scripts(ctx):
    return ctx.home + "/.config/tmux/scripts"

def _write_local_conf(ctx):
    r = ctx.run("which", ["fish"])
    fish_path = r.stdout.strip()
    if fish_path:
        local_conf = ctx.home + "/.config/tmux/local.conf"
        ctx.write_file(local_conf, "set -g default-shell " + fish_path + "\n")
        ctx.log("tmux-config: wrote local.conf with default-shell=" + fish_path)
    else:
        ctx.log("tmux-config: fish not found — local.conf not written; tmux will use default shell")

def _install_deps():
    pkg(manager = "brew", name = "osx-cpu-temp")
    pkg(manager = "python", name = "libtmux")

def install(ctx):
    tpm_path = ctx.home + "/.tmux/plugins/tpm"
    if not ctx.file_exists(tpm_path):
        ctx.git_clone("https://github.com/tmux-plugins/tpm", tpm_path)
        ctx.log("tmux-config: cloned TPM — launch tmux and press prefix + I to install plugins")

    ctx.link_file("tmux.conf", ctx.home + "/.tmux.conf")

    fish_confd = ctx.home + "/.config/fish/conf.d"
    ctx.mkdir(fish_confd)
    ctx.link_file("conf.d/tmux-autostart.fish", fish_confd + "/tmux-autostart.fish")

    ctx.mkdir(ctx.home + "/.config/tmux")
    scripts = _tmux_scripts(ctx)
    ctx.mkdir(scripts)
    for script in _SCRIPTS:
        ctx.link_file("scripts/" + script, scripts + "/" + script)

    ctx.link_file("post-tpm.conf", ctx.home + "/.config/tmux/post-tpm.conf")

    _write_local_conf(ctx)
    _install_deps()
    ctx.log("tmux-config: linked tmux configuration")

def upgrade(ctx):
    install(ctx)
    uppkg(manager = "brew", name = "osx-cpu-temp")
    uppkg(manager = "python", name = "libtmux")
    tpm_path = ctx.home + "/.tmux/plugins/tpm"
    if ctx.file_exists(tpm_path):
        ctx.run("git", ["-C", tpm_path, "pull", "--ff-only"])
        ctx.log("tmux-config: updated TPM")

def verify(ctx):
    ok = True
    for path in [
        ctx.home + "/.tmux.conf",
        ctx.home + "/.config/tmux/local.conf",
        ctx.home + "/.config/tmux/post-tpm.conf",
    ]:
        if not ctx.file_exists(path):
            ctx.log("tmux-config: MISSING " + path)
            ok = False
    for script in _SCRIPTS:
        p = _tmux_scripts(ctx) + "/" + script
        if not ctx.file_exists(p):
            ctx.log("tmux-config: MISSING " + p)
            ok = False
    if ok:
        ctx.log("tmux-config: OK")

def uninstall(ctx):
    unpkg(manager = "brew", name = "osx-cpu-temp")
    unpkg(manager = "python", name = "libtmux")
    ctx.remove_symlink(ctx.home + "/.tmux.conf")
    ctx.remove_symlink(ctx.home + "/.config/fish/conf.d/tmux-autostart.fish")
    ctx.remove_symlink(ctx.home + "/.config/tmux/post-tpm.conf")
    scripts = _tmux_scripts(ctx)
    for script in _SCRIPTS:
        ctx.remove_symlink(scripts + "/" + script)
    ctx.rmdir(scripts)
    local_conf = ctx.home + "/.config/tmux/local.conf"
    if ctx.file_exists(local_conf):
        ctx.run("rm", ["-f", local_conf])
    ctx.rmdir(ctx.home + "/.config/tmux")
    ctx.log("tmux-config: removed tmux configuration")
