# components/tmux-config.star
#
# platform: all
# after:    ["@stdlib//components/tmux", "@stdlib//components/sesh", "@stdlib//components/fish"]
#
# Links tmux configuration and status bar scripts into their canonical locations.
# Scripts are committed as executable (chmod +x in repo); no chmod needed at link time.
#
# TPM bootstrap (one-time, run after first meowctl apply):
#   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
#   Then launch tmux and press prefix + I

after = ["@stdlib//components/tmux", "@stdlib//components/sesh", "@stdlib//components/fish"]

_SCRIPTS = [
    "tmux-keyboard.sh",
    "tmux-vpn.sh",
    "tmux-focus.sh",
    "tmux-cpu.sh",
    "tmux-memory.sh",
]

def _tmux_scripts(ctx):
    return ctx.home + "/.config/tmux/scripts"

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

    ctx.log("tmux-config: linked tmux configuration")

def upgrade(ctx):
    install(ctx)
    tpm_path = ctx.home + "/.tmux/plugins/tpm"
    if ctx.file_exists(tpm_path):
        ctx.run("git", ["-C", tpm_path, "pull", "--ff-only"])
        ctx.log("tmux-config: updated TPM")

def uninstall(ctx):
    ctx.remove_symlink(ctx.home + "/.tmux.conf")
    ctx.remove_symlink(ctx.home + "/.config/fish/conf.d/tmux-autostart.fish")
    scripts = _tmux_scripts(ctx)
    for script in _SCRIPTS:
        ctx.remove_symlink(scripts + "/" + script)
    # Best-effort directory cleanup; ignored if directories are non-empty.
    ctx.rmdir(scripts)
    ctx.rmdir(ctx.home + "/.config/tmux")
    ctx.log("tmux-config: removed tmux configuration")
