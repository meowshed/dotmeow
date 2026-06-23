# components/karabiner-config.star
#
# platform: macos
# after:    ["@stdlib//components/karabiner_elements"]
#
# Renders karabiner.json from karabiner.json.tmpl and writes it to
# ~/.config/karabiner/karabiner.json (copy, not symlink).
#
# Caps Lock: tap → Escape, hold → Left Control on all keyboards.
#
# NOTE: Karabiner-Elements writes GUI changes directly back to karabiner.json.
# Running `meowctl apply` again resets the file from the template. Keep any
# device-specific rules in the template; incidental GUI changes will be lost.

platforms = ["macos"]
after = ["@stdlib//components/karabiner_elements"]

def install(ctx):
    d = ctx.home + "/.config/karabiner"
    ctx.mkdir(d)
    dest = d + "/karabiner.json"

    ktype = ctx.prompt("Keyboard type? (iso/ansi, leave blank for iso)").lower().strip()
    if ktype not in ["iso", "ansi"]:
        ktype = "iso"

    content = ctx.render_file("karabiner.json.tmpl", {"KEYBOARD_TYPE": ktype})
    ctx.write_file(dest, content)
    ctx.log("karabiner-config: wrote karabiner.json with keyboard_type=" + ktype)

def upgrade(ctx):
    dest = ctx.home + "/.config/karabiner/karabiner.json"
    if ctx.file_exists(dest):
        # Read the current keyboard_type from the on-disk file so we can
        # re-render the template without prompting again.
        r = ctx.run("plutil", ["-extract",
                    "profiles.0.virtual_hid_keyboard.keyboard_type",
                    "raw", dest])
        ktype = r.stdout.strip().lower()
        if ktype not in ["iso", "ansi"]:
            ktype = "iso"
        content = ctx.render_file("karabiner.json.tmpl", {"KEYBOARD_TYPE": ktype})
        ctx.write_file(dest, content)
        ctx.log("karabiner-config: re-rendered template with keyboard_type=" + ktype)
    else:
        install(ctx)

def verify(ctx):
    dest = ctx.home + "/.config/karabiner/karabiner.json"
    if ctx.file_exists(dest):
        ctx.log("karabiner-config: OK")
    else:
        ctx.log("karabiner-config: MISSING " + dest)

def uninstall(ctx):
    ctx.run("rm", ["-f", ctx.home + "/.config/karabiner/karabiner.json"])
    ctx.log("karabiner-config: removed karabiner.json")
