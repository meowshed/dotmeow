# components/git-config.star
#
# Links ~/.config/git/config from this repo.
# On first install, prompts for name + email and writes ~/.config/git/local.gitconfig.
# local.gitconfig is not tracked — identity stays private.

def install(ctx):
    d = ctx.home + "/.config/git"
    ctx.mkdir(d)
    ctx.link_file("config", d + "/config")
    ctx.link_file("ignore", d + "/ignore")

    if not ctx.file_exists(d + "/local.gitconfig"):
        name = ctx.prompt("Git user name")
        email = ctx.prompt("Git user email")
        content = ctx.render_file("local.gitconfig.tmpl", {
            "GIT_USER_NAME": name,
            "GIT_USER_EMAIL": email,
        })
        ctx.write_file(d + "/local.gitconfig", content)

def upgrade(ctx):
    d = ctx.home + "/.config/git"
    ctx.link_file("config", d + "/config")
    ctx.link_file("ignore", d + "/ignore")

def uninstall(ctx):
    d = ctx.home + "/.config/git"
    ctx.remove_symlink(d + "/config")
    ctx.remove_symlink(d + "/ignore")
    # local.gitconfig is user data — not removed
