# components/gh-config.star
#
# platform: all
# after:    ["@stdlib//components/gh", "@stdlib//components/fish"]
#
# Links gh config into ~/.config/gh/config.yml.
# hosts.yml is managed by `gh auth login` — not touched.
# Also installs a fish conf.d snippet that exports GITHUB_TOKEN from gh's
# stored token so mise and other tools can make authenticated GitHub API calls.

after = ["@stdlib//components/gh", "@stdlib//components/fish"]

def install(ctx):
    d = ctx.home + "/.config/gh"
    ctx.mkdir(d)
    ctx.link_file("config.yml", d + "/config.yml")
    fish_confd = ctx.home + "/.config/fish/conf.d"
    ctx.mkdir(fish_confd)
    ctx.link_file("conf.d/github-token.fish", fish_confd + "/github-token.fish")

def upgrade(ctx):
    install(ctx)

def verify(ctx):
    ok = True
    for p in [ctx.home + "/.config/gh/config.yml",
              ctx.home + "/.config/fish/conf.d/github-token.fish"]:
        if not ctx.file_exists(p):
            ctx.log("gh-config: MISSING " + p)
            ok = False
    if ok:
        ctx.log("gh-config: OK")

def uninstall(ctx):
    ctx.unlink_file(ctx.home + "/.config/gh/config.yml")
    ctx.remove_symlink(ctx.home + "/.config/fish/conf.d/github-token.fish")
