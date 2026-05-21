# components/git-config.star
#
# Links ~/.config/git/config from this repo.
# On first install, prompts for name + email and writes ~/.config/git/local.gitconfig.
# local.gitconfig is not tracked — identity stays private.

def install(ctx):
    ctx.mkdir("~/.config/git")
    ctx.link_file("config", "~/.config/git/config")
    ctx.link_file("ignore", "~/.config/git/ignore")

    if not ctx.file_exists("~/.config/git/local.gitconfig"):
        name = ctx.prompt("Git user name")
        email = ctx.prompt("Git user email")
        content = ctx.render_file("local.gitconfig.tmpl", {
            "GIT_USER_NAME": name,
            "GIT_USER_EMAIL": email,
        })
        ctx.write_file("~/.config/git/local.gitconfig", content)

def upgrade(ctx):
    ctx.link_file("config", "~/.config/git/config")
    ctx.link_file("ignore", "~/.config/git/ignore")

def uninstall(ctx):
    ctx.unlink_file("~/.config/git/config")
    ctx.unlink_file("~/.config/git/ignore")
    # local.gitconfig is user data — not removed

def shell(ctx):
    if ctx.shell == "fish":
        ctx.emit("set -gx PAGER delta")
    elif ctx.shell in ("bash", "zsh", "posix"):
        ctx.emit("export PAGER=delta")
