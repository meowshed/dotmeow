# My environment

- **Shell: fish.** Commands and snippets you give me to run go in fish syntax (`set -x VAR value`, `; and` / `; or`, `function … end`, `test` instead of `[[ ]]`). Scripts saved to files can be bash or sh with a shebang.
- **Terminal: tmux.** I work inside tmux. For long-running things (dev servers, watchers, log tails), suggest running them in a separate tmux window or pane rather than blocking the session.
- **Editor: Neovim.** Never suggest VS Code or other IDEs. When editor setup or config comes up, give Neovim/Lua. Reference code as `path/to/file:line` so I can jump to it.
