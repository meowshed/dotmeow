#!/bin/bash
# which-key for tmux — generated from the live key tables, never hand-written.
#
#   tmux-which-key.sh              open the picker on the prefix table
#   tmux-which-key.sh --list TBL   print one table (used by fzf's reload binds)
#
# Merges two listings per key: `list-keys` for the bound command, `list-keys -N`
# for its note. A bind with no note still shows, described by its command, so
# this cannot drift from the config.
#
# Enter re-runs the command through source-file, not send-keys: send-keys writes
# into the pane and never reaches tmux's key tables.
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"

readonly SELF="${BASH_SOURCE[0]}"
readonly DIM=$'\033[38;5;242m'
readonly ACC=$'\033[38;5;110m'
readonly RST=$'\033[0m'
readonly TAB=$'\t'

# "<key>\t<command>" for every bind in the table.
keys_and_commands() {
    tmux list-keys -T "$1" 2>/dev/null | awk -v OFS="$TAB" '
        {
            t = 0
            for (i = 1; i <= NF; i++) if ($i == "-T") { t = i; break }
            if (!t) next
            key = $(t + 2)
            sub(/^\\/, "", key)
            cmd = ""
            for (i = t + 3; i <= NF; i++) cmd = cmd (cmd == "" ? "" : " ") $i
            if (cmd != "") print key, cmd
        }'
}

# "<key>\t<note>" for the binds that carry one. The listing renders each row as
# "<prefix keys> <key>   <note>"; the key is the last field before the gap.
keys_and_notes() {
    tmux list-keys -N -T "$1" 2>/dev/null |
        sed -E 's/^C-a +//; s/^[[:space:]]+//' |
        awk -v OFS="$TAB" '
            {
                key = $1
                note = ""
                for (i = 2; i <= NF; i++) note = note (note == "" ? "" : " ") $i
                if (note != "") print key, note
            }'
}

# Descriptions for binds we do not own. Matched on command text, never re-bound:
# tmux has no note-only API, so adding -N to a plugin's bind would mean
# re-declaring and freezing its command.
FALLBACKS='
previous-space|Move to previous whitespace-separated word
next-space-end|Move to end of next whitespace-separated word
next-space|Move to next whitespace-separated word
jump-to-mark|Jump to the mark
set-mark|Set the mark here
scroll-middle|Centre the cursor line
select-pane -L|Select pane to the left
select-pane -D|Select pane below
select-pane -U|Select pane above
select-pane -R|Select pane to the right
select-pane -l|Select the previously used pane
send-keys -X cancel|Leave copy mode
jump-reverse|Repeat the last character jump, reversed
jump-again|Repeat the last character jump
jump-forward|Jump forward to a character
jump-backward|Jump back to a character
jump-to-forward|Jump forward, stopping before the character
jump-to-backward|Jump back, stopping after the character
previous-paragraph|Move to previous paragraph
next-paragraph|Move to next paragraph
next-matching-bracket|Jump to the matching bracket
back-to-indentation|Move to first non-blank character
copy_cursor_word|Search for the word under the cursor
command-prompt -N|Prefix the next motion with a repeat count
middle-line|Move to the middle line
top-line|Move to the top line
bottom-line|Move to the bottom line
scroll-up|Scroll up
scroll-down|Scroll down
begin-selection|Begin selection
clear-selection|Clear the selection
stop-selection|Stop extending the selection
other-end|Jump to the other end of the selection
append-selection|Append the selection to the buffer
pipe|Pipe the selection to a command
refresh-from-pane|Refresh the pane contents
toggle-position|Move the copy-mode indicator out of the way
select-word|Select word
last-pane|Switch to the previously used pane
last-window|Switch to the previously used window
next-window|Next window
previous-window|Previous window
list-buffers|List paste buffers
show-messages|Show the tmux message log
swap-pane -U|Swap pane with the one above
swap-pane -D|Swap pane with the one below
select-window|Select a window by index
send-keys C-l|Clear the screen
source-file|Reload the tmux config
tmux-fzf-url|Open a URL from the scrollback
tmux-thumbs|Copy hints — pick text off the screen
fuzzback|Fuzzy-search the scrollback
install_plugins|Install plugins (TPM)
update_plugins|Update plugins (TPM)
clean_plugins|Remove plugins no longer listed (TPM)
copy_line.sh|Copy the current line
tmux-yank|Copy to the system clipboard
send-keys .C-h.|Select pane left (passes through to vim)
send-keys .C-j.|Select pane down (passes through to vim)
send-keys .C-k.|Select pane up (passes through to vim)
send-keys .C-l.|Select pane right (passes through to vim)
begin-selection|Begin selection
rectangle-toggle|Toggle block selection
copy-pipe-and-cancel|Copy selection and leave copy mode
copy-selection-and-cancel|Copy selection and leave copy mode
select-word|Select word
select-line|Select line
search-again|Repeat the last search
search-reverse|Repeat the last search, reversed
history-top|Jump to the top of the scrollback
history-bottom|Jump to the bottom of the scrollback
page-up|Page up
page-down|Page down
halfpage-up|Half page up
halfpage-down|Half page down
cursor-left|Move cursor left
cursor-down|Move cursor down
cursor-up|Move cursor up
cursor-right|Move cursor right
next-word-end|Move to end of next word
next-word|Move to next word
previous-word|Move to previous word
start-of-line|Move to start of line
end-of-line|Move to end of line
goto-line|Jump to line
send -X cancel|Leave copy mode
MouseD|Mouse binding
Mouse|Mouse binding
Wheel|Mouse wheel binding
'

list_table() {
    local table="$1" notes
    notes=$(keys_and_notes "$table")
    keys_and_commands "$table" |
        NOTES="$notes" FALLBACKS="$FALLBACKS" awk -F"$TAB" -v OFS="$TAB" \
            -v acc="$ACC" -v dim="$DIM" -v rst="$RST" '
        BEGIN {
            n = split(ENVIRON["NOTES"], lines, "\n")
            for (i = 1; i <= n; i++) {
                split(lines[i], kv, "\t")
                note[kv[1]] = kv[2]
            }
            nf = split(ENVIRON["FALLBACKS"], frows, "\n")
            nfb = 0
            for (i = 1; i <= nf; i++) {
                if (frows[i] == "") continue
                split(frows[i], fkv, "|")
                nfb++
                fpat[nfb] = fkv[1]
                ftxt[nfb] = fkv[2]
            }
        }
        # A real -N note wins; then the fallback table, in declaration order so
        # the more specific pattern is listed first; then the command itself.
        function describe(key, cmd,    i) {
            if (key in note) return note[key]
            for (i = 1; i <= nfb; i++)
                if (cmd ~ fpat[i] || key ~ fpat[i]) return ftxt[i]
            return cmd
        }
        {
            key = $1; cmd = $2
            # value, display key, display description, command
            print key, acc key rst, describe(key, cmd), dim cmd rst
        }' | sort -f
}

if [ "$1" = "--list" ]; then
    list_table "$2"
    exit 0
fi

# Table name in the prompt, switches in the header.
readonly SWITCHES='^p prefix   ^v copy-mode   ^r root'

# Plain fzf: the binding already opened a floating pane. --height=100% overrides
# the --height=40% in FZF_DEFAULT_OPTS.
out=$(list_table prefix | fzf \
    --ansi --border=none --height=100% --delimiter="$TAB" --with-nth=2,3,4 --nth=1,2,3 \
    --prompt 'prefix ❯ ' \
    --header "$SWITCHES" \
    --bind "ctrl-p:reload($SELF --list prefix)+change-prompt(prefix ❯ )" \
    --bind "ctrl-v:reload($SELF --list copy-mode-vi)+change-prompt(copy-mode ❯ )" \
    --bind "ctrl-r:reload($SELF --list root)+change-prompt(root ❯ )")

[ -n "$out" ] || exit 0

cmd=$(printf '%s' "$out" | cut -d"$TAB" -f4 | sed -E $'s/\033\\[[0-9;]*m//g')
[ -n "$cmd" ] || exit 0

script="${TMPDIR:-/tmp}/tmux-which-key.$$"
printf '%s\n' "$cmd" >"$script"
tmux source-file "$script"
rm -f "$script"
exit 0
