#!/bin/bash
# Builds the key-hint half of the second status line and stores it in @wk_hint.
#
# Run on config load, not every status interval: the string only changes when
# the bindings do. Labels are curated; which entries survive is not — an unbound
# key is dropped on the next reload.
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"

# key <US> icon <US> label <US> display key (blank = use the key), in display
# order. Short list on purpose: everything omitted is one `?` away, and
# destructive binds stay out. The icon field is kept but empty — Nerd Font
# glyphs read as abstract shapes at this size.
readonly US=$'\037'
HINTS=(
    "[${US}${US}copy${US}"
    "v${US}${US}right${US}"
    "s${US}${US}down${US}"
    "z${US}${US}zoom${US}"
    "w${US}${US}sess${US}"
    "f${US}${US}jump${US}"
    "g${US}${US}git${US}"
    "?${US}${US}keys${US}"
)

# Copy mode has its own table and its own easily-forgotten bindings.
COPY_HINTS=(
    "v${US}${US}sel${US}"
    "V${US}${US}line${US}"
    "C-v${US}${US}block${US}"
    "y${US}${US}yank${US}"
    "/${US}${US}find${US}"
    "n${US}${US}next${US}"
    "Escape${US}${US}exit${US}Esc"
)

# list-keys escapes special keys, so check both the bare and the escaped spelling.
bound() {
    local table="$1" key="$2"
    tmux list-keys -T "$table" 2>/dev/null |
        awk -v k="$key" '''{
            for (i = 1; i <= NF; i++) if ($i == "-T") { f = $(i + 2); break }
            sub(/^\\/, "", f)
            if (f == k) { found = 1; exit }
        } END { exit !found }'''
}

render() {
    local table="$1" key icon label out=""
    shift
    for hint in "$@"; do
        IFS="$US" read -r key icon label disp <<<"$hint"
        bound "$table" "$key" || continue
        # Brackets read as a keycap and separate entries without a delimiter.
        [ -n "$icon" ] && out+="#[fg=#{@thm_overlay_0}]${icon} "
        out+="#[fg=#{@thm_surface_2}][#[fg=#{@thm_blue}]${disp:-$key}#[fg=#{@thm_surface_2}]]#[fg=#{@thm_overlay_1}] ${label}  "
    done
    printf '%s' "$out"
}

tmux set -g @wk_hint "$(render prefix "${HINTS[@]}")"
tmux set -g @wk_hint_copy "$(render copy-mode-vi "${COPY_HINTS[@]}")"
