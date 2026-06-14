# components/fish-config.star
#
# platform: all
# after:    ["@stdlib//components/fish"]
#
# Links a full fish configuration into ~/.config/fish/.
#
# Structure:
#   config.fish              — minimal entry point (meowctl shell integration)
#   conf.d/
#     00-environment.fish    — locale, PATH, env vars
#     10-vi-mode.fish        — vi key bindings, cursor shapes
#     20-tools.fish          — interactive tool extras (fzf, zoxide fallback)
#     30-aliases.fish        — aliases, abbreviations, function wrappers
#     40-ai.fish             — Claude/OpenCode/Codex launch helpers
#     99-local.fish          — machine-specific overrides (stub)
#   functions/               — autoloaded custom functions
#   completions/             — custom completions

after = ["@stdlib//components/fish"]

def install(ctx):
    fish = ctx.home + "/.config/fish"
    ctx.mkdir(fish)
    ctx.mkdir(fish + "/conf.d")
    ctx.mkdir(fish + "/functions")
    ctx.mkdir(fish + "/completions")

    # Main config
    ctx.link_file("config.fish", fish + "/config.fish")

    # conf.d snippets (numbered load order)
    ctx.link_file("conf.d/00-environment.fish", fish + "/conf.d/00-environment.fish")
    ctx.link_file("conf.d/05-ulimit.fish",      fish + "/conf.d/05-ulimit.fish")
    ctx.link_file("conf.d/10-vi-mode.fish",     fish + "/conf.d/10-vi-mode.fish")
    ctx.link_file("conf.d/20-tools.fish",      fish + "/conf.d/20-tools.fish")
    ctx.link_file("conf.d/30-aliases.fish",    fish + "/conf.d/30-aliases.fish")
    ctx.link_file("conf.d/40-ai.fish",         fish + "/conf.d/40-ai.fish")
    ctx.link_file("conf.d/99-local.fish",      fish + "/conf.d/99-local.fish")
    ctx.link_file("conf.d/zz-fzf-bindings.fish", fish + "/conf.d/zz-fzf-bindings.fish")

    # Autoloaded functions
    ctx.link_file("functions/mkcd.fish",   fish + "/functions/mkcd.fish")
    ctx.link_file("functions/cf.fish",     fish + "/functions/cf.fish")
    ctx.link_file("functions/vf.fish",     fish + "/functions/vf.fish")
    ctx.link_file("functions/gs.fish",     fish + "/functions/gs.fish")
    ctx.link_file("functions/rgfi.fish",   fish + "/functions/rgfi.fish")
    ctx.link_file("functions/gli.fish",    fish + "/functions/gli.fish")
    ctx.link_file("functions/clip.fish",   fish + "/functions/clip.fish")

    # Completions stub
    ctx.link_file("completions/README.fish", fish + "/completions/README.fish")

    ctx.log("fish-config: linked full fish configuration")

def upgrade(ctx):
    fish = ctx.home + "/.config/fish"

    # Remove legacy aliases.fish (renamed to 30-aliases.fish)
    ctx.remove_symlink(fish + "/conf.d/aliases.fish")

    install(ctx)

def uninstall(ctx):
    fish = ctx.home + "/.config/fish"
    ctx.remove_symlink(fish + "/config.fish")
    ctx.remove_symlink(fish + "/conf.d/00-environment.fish")
    ctx.remove_symlink(fish + "/conf.d/05-ulimit.fish")
    ctx.remove_symlink(fish + "/conf.d/10-vi-mode.fish")
    ctx.remove_symlink(fish + "/conf.d/20-tools.fish")
    ctx.remove_symlink(fish + "/conf.d/30-aliases.fish")
    ctx.remove_symlink(fish + "/conf.d/40-ai.fish")
    ctx.remove_symlink(fish + "/conf.d/99-local.fish")
    ctx.remove_symlink(fish + "/conf.d/zz-fzf-bindings.fish")
    ctx.remove_symlink(fish + "/conf.d/aliases.fish")  # legacy
    ctx.remove_symlink(fish + "/functions/mkcd.fish")
    ctx.remove_symlink(fish + "/functions/cf.fish")
    ctx.remove_symlink(fish + "/functions/vf.fish")
    ctx.remove_symlink(fish + "/functions/gs.fish")
    ctx.remove_symlink(fish + "/functions/rgfi.fish")
    ctx.remove_symlink(fish + "/functions/gli.fish")
    ctx.remove_symlink(fish + "/functions/clip.fish")
    ctx.remove_symlink(fish + "/completions/README.fish")
    ctx.log("fish-config: removed fish configuration")
