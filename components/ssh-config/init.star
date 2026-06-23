# components/ssh-config.star
#
# platform: ["macos"]
# after:    ["@stdlib//components/openssh"]
#
# Links ~/.ssh/config from this repo.
# Creates ~/.ssh/sockets/ for ControlMaster multiplexing.

platforms = ["macos"]
after = ["@stdlib//components/openssh"]

def install(ctx):
    ctx.link_file("config", ctx.home + "/.ssh/config")
    ctx.mkdir(ctx.home + "/.ssh/sockets")

def upgrade(ctx):
    install(ctx)

def verify(ctx):
    ok = True
    for p in [ctx.home + "/.ssh/config", ctx.home + "/.ssh/sockets"]:
        if not ctx.file_exists(p):
            ctx.log("ssh-config: MISSING " + p)
            ok = False
    if ok:
        ctx.log("ssh-config: OK")

def uninstall(ctx):
    ctx.unlink_file(ctx.home + "/.ssh/config")
