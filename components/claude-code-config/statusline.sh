#!/usr/bin/env bash
# ~/.claude/statusline.sh — managed by dotmeow.
# Catppuccin Mocha status line for Claude Code.
#
# Claude Code pipes a JSON session object on stdin and renders whatever this
# script prints to stdout as the status line. Segments: model · dir · git branch.
# Requires: jq (already a dotmeow dependency via the shell tooling).

input=$(cat)

if command -v jq >/dev/null 2>&1; then
  model=$(printf '%s' "$input" | jq -r '.model.display_name // "Claude"')
  dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
else
  model="Claude"
  dir=""
fi
[ -z "$dir" ] && dir="$PWD"

# Home-relative display path.
disp=${dir/#$HOME/\~}

# Git branch + dirty flag (silent outside a repo).
branch=$(git -C "$dir" branch --show-current 2>/dev/null)
dirty=""
if [ -n "$branch" ]; then
  git -C "$dir" diff --quiet --ignore-submodules HEAD 2>/dev/null || dirty="*"
fi

# Catppuccin Mocha palette (truecolor). Neutral enough to read on Latte too.
c_mauve=$'\033[38;2;203;166;247m'   # mauve  — model
c_blue=$'\033[38;2;137;180;250m'    # blue   — path
c_green=$'\033[38;2;166;227;161m'   # green  — branch
c_peach=$'\033[38;2;250;179;135m'   # peach  — dirty marker
c_over=$'\033[38;2;108;112;134m'    # overlay0 — separators
rst=$'\033[0m'

sep="${c_over} · ${rst}"
out="${c_mauve}󰚩 ${model}${rst}"
out+="${sep}${c_blue} ${disp}${rst}"
[ -n "$branch" ] && out+="${sep}${c_green} ${branch}${c_peach}${dirty}${rst}"

printf '%s' "$out"
