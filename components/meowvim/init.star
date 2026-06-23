# components/meowvim.star
#
# platform: all
# after:    ["@stdlib//components/neovim"]
#
# Clones retran/meowvim into ~/.config/nvim.
# On upgrade, fast-forwards the clone. On uninstall, removes the directory.

after = ["@stdlib//components/neovim"]

def install(ctx):
    dst = ctx.home + "/.config/nvim"
    if ctx.file_exists(dst):
        if not ctx.file_exists(dst + "/.git"):
            ctx.log("meowvim: %s exists but is not a git repo — move it aside before installing" % dst)
            return
        ctx.log("meowvim: %s already exists — skipping clone" % dst)
    else:
        ctx.git_clone("https://github.com/retran/meowvim.git", dst)
        ctx.log("meowvim: cloned to %s" % dst)

def upgrade(ctx):
    dst = ctx.home + "/.config/nvim"
    # --ff-only fails if the remote was force-pushed; run `git fetch && git reset --hard @{u}` manually in that case.
    ctx.run("git", ["-C", dst, "pull", "--ff-only"])

def verify(ctx):
    dst = ctx.home + "/.config/nvim"
    if ctx.file_exists(dst + "/.git"):
        ctx.log("meowvim: OK")
    elif ctx.file_exists(dst):
        ctx.log("meowvim: EXISTS but not a git repo — run meowctl apply to repair")
    else:
        ctx.log("meowvim: MISSING " + dst)

def uninstall(ctx):
    dst = ctx.home + "/.config/nvim"
    ctx.log("meowvim: removing %s — ensure your config is committed before proceeding" % dst)
    ctx.run("rm", ["-rf", dst])
    ctx.log("meowvim: removed %s" % dst)

def shell(ctx):
    if ctx.shell == "fish":
        ctx.emit("set -gx EDITOR nvim")
        ctx.emit("set -gx VISUAL nvim")
    elif ctx.shell in ("bash", "zsh", "posix"):
        ctx.emit("export EDITOR=nvim")
        ctx.emit("export VISUAL=nvim")
