# ~/.config/fish/conf.d/20-tools.fish
# Interactive tool initialisation that is NOT emitted by meowctl hook shell.
# meowctl already handles: mise, starship, zoxide (with --cmd cd), direnv.

if status is-interactive
    # -----------------------------------------------------------------------
    # zoxide fallback — if meowctl hook is absent, initialise directly.
    # When meowctl is present this is a no-op (zoxide refuses double-init).
    # -----------------------------------------------------------------------
    if command -q zoxide
        and not functions -q __zoxide_z
        zoxide init --cmd cd fish | source
    end
end
