# dotmeow

Reference dotfiles managed with [meowctl](https://github.com/meowshed/meowctl).

## Bootstrap

```sh
meowctl bootstrap https://github.com/meowshed/dotmeow
```

Downloads this repo, resolves dependencies, and installs all components.

## Layout

```
init.star          # component declarations
deps.mod           # module dependencies
local.star         # machine-specific additions (gitignored)
components/        # local component .star files + config assets
hooks/             # extension hooks for stdlib components + assets
```

## Components

### Stdlib bundles

| Bundle | Description |
|--------|-------------|
| `@stdlib//bundles/modern-shell` | fish, bash, starship, atuin, zoxide, fzf, bat, eza, ripgrep, fd, btop, dust, duf, sd, dasel, miller, jq, yq, glow, tealdeer, navi, watchexec, gum, direnv, age, gpg, openssl, mkcert, openssh, curl, wget, zellij, neovim, fish plugins (bass, fzf, autopair, sponge) |
| `@stdlib//bundles/modern-macos` | ghostty, fonts, keka, maccy, caffeine, displayplacer, mole |
| `@stdlib//bundles/github` | git, lazygit, delta, forgit, gh, git_lfs, act |
| `@stdlib//bundles/shell-development` | shellcheck, shfmt |
| `@stdlib//bundles/lua-development` | lua-language-server, stylua, luarocks |

### Stdlib individual components

| Component | Description |
|-----------|-------------|
| `@stdlib//components/brew` | Homebrew (macOS) |
| `@stdlib//components/mise` | Tool version manager |
| `@stdlib//components/hammerspoon` | macOS automation framework |
| `@stdlib//components/imagemagick` | Image processing CLI |
| `@stdlib//components/ffmpeg` | Audio/video processing |
| `@stdlib//components/vhs` | Terminal GIF recorder |
| `@stdlib//components/typora` | Markdown editor |
| `@stdlib//components/obsidian` | Knowledge base |
| `@stdlib//components/vscode` | Visual Studio Code |
| `@stdlib//components/orbstack` | Docker and Linux VMs |
| `@stdlib//components/docker_cli` | Docker CLI |
| `@stdlib//components/worktrunk` | Git worktree manager |
| `@stdlib//components/gpg` | GPG encryption |
| `@stdlib//components/hyperfine` | CLI benchmarking |
| `@stdlib//components/tokei` | Code statistics |
| `@stdlib//components/procs` | Modern `ps` replacement |
| `@stdlib//components/xh` | Modern HTTP client |
| `@stdlib//components/pandoc` | Document conversion |
| `@stdlib//components/ncdu` | Disk usage viewer |
| `@stdlib//components/drawio` | Diagramming tool |

### Custom config components

| Component | Description |
|-----------|-------------|
| `fish-config` | Full fish shell config (see [Fish Aliases & Functions](#fish-aliases--functions)) |
| `git-config` | Git aliases, delta, global ignore |
| `ssh-config` | SSH client config with ControlMaster |
| `atuin-config` | Local-only atuin with Catppuccin Mocha theme |
| `gh-config` | GitHub CLI config reference |
| `meowvim` | Clone [retran/meowvim](https://github.com/retran/meowvim) into `~/.config/nvim` |
| `zellij-config` | Zellij config, layouts, themes, and fish tab-naming hook |
| `starship-config` | Starship prompt (Catppuccin Mocha) |
| `bat-config` | Bat config and theme |
| `ghostty-config` | Ghostty terminal config |
| `lazygit-config` | Lazygit config |
| `eza-config` | Eza config and Catppuccin Mocha theme |
| `glow-config` | Glow markdown renderer config |
| `ripgrep-config` | Ripgrep config with shell hook for `RIPGREP_CONFIG_PATH` |
| `btop-config` | Btop config and Catppuccin Mocha theme |
| `tealdeer-config` | Tealdeer (tldr) config |
| `fzf-config` | FZF Catppuccin Mocha theme and keybinding options |
| `hammerspoon-config` | Hammerspoon init.lua with adaptive keyboard layouts, zjstatus widgets, meowvim keyboard layouts |

### Standalone meowctl modules (deps.mod)

| Module | Description |
|--------|-------------|
| `adaptive-keyboard-layouts` | Hammerspoon Spoon: auto-switch macOS keyboard layouts per connected keyboard |
| `zjstatus-widgets` | Hammerspoon Spoon: event-driven zjstatus pipe widgets for zellij |
| `meowvim-keyboard-layouts` | Hammerspoon Spoon: switch keyboard layout based on Neovim mode via Ghostty title |

### Extension Hooks

| Hook | Extends | What it does |
|------|---------|--------------|
| `hooks/meowvim.star` | `@stdlib//components/neovim` | Logs reminder to sync lazy.nvim plugins |

## Fish Aliases & Functions

Fish is the primary shell. Config lives in `~/.config/fish/` and is structured as:

```
config.fish              # minimal entry point (meowctl shell integration)
conf.d/
  00-environment.fish    # locale, PATH, env vars
  10-vi-mode.fish        # vi key bindings, cursor shapes
  20-tools.fish          # interactive tool extras (zoxide fallback)
  30-aliases.fish        # aliases, abbreviations, function wrappers
  99-local.fish          # machine-specific overrides (stub)
functions/               # autoloaded custom functions
completions/             # custom completions
```

### Abbreviations (`abbr` — expands visibly in history)

| Abbr | Expansion | Condition |
|------|-----------|-----------|
| `g` | `git` | git installed |
| `gd` | `git diff` | git installed |
| `ga` | `git add` | git installed |
| `gc` | `git commit` | git installed |
| `gp` | `git push` | git installed |
| `gl` | `git pull` | git installed |
| `rgh` | `rg --hidden` | ripgrep installed |
| `rgi` | `rg --no-ignore` | ripgrep installed |
| `rgl` | `rg --files-with-matches` | ripgrep installed |

### Function wrappers (`function --wraps` — replaces builtin)

| Function | Wraps | Description |
|----------|-------|-------------|
| `ls` | `eza` | Directory listing with git integration |
| `l` | `eza -l` | Long listing |
| `la` | `eza -la` | Long listing, including hidden |
| `ll` | `eza -l --git` | Long listing with git status |
| `tree` | `eza --tree` | Tree view |
| `lt` | `eza --tree --level=2` | Tree, 2 levels deep |
| `lta` | `eza --tree --level=2 -a` | Tree, 2 levels, hidden included |
| `cat` | `bat --paging=never` | Syntax-highlighted cat |
| `less` | `bat --paging=always` | Syntax-highlighted pager |
| `help` | — | Show `--help` via bat |
| `df` | `duf` | Better disk usage |
| `vim` | `nvim` | Neovim |
| `vi` | `nvim` | Neovim |

### Autoloaded functions (`functions/*.fish`)

| Function | Description | Requirements |
|----------|-------------|--------------|
| `mkcd <dir>` | Create directory and cd into it | — |
| `cf` | Fuzzy-find and cd into a directory | fd + fzf |
| `vf` | Fuzzy-find and open file(s) in nvim | fd + fzf + bat |
| `gs` | Git status with short branch format (`git status -sb`) | git |
| `rgfi <query>` | Interactive ripgrep with fzf preview | rg + fzf + bat |
| `gli` | Interactive git log with fzf preview | git + fzf |

### Zoxide integration

Zoxide replaces `cd` via `zoxide init --cmd cd fish | source` (emitted by the
`@stdlib//components/zoxide` shell hook). This means:

- `cd <partial-path>` — jumps to best match from history
- `cdi` (or `zi`) — interactive selection with fzf
- All standard `cd` flags (`-`, `..`, etc.) continue to work

### Tool integrations (via `meowctl hook shell`)

The following are initialised automatically by meowctl and do not require
manual configuration:

| Tool | What meowctl emits |
|------|-------------------|
| mise | `mise activate fish \| source` |
| starship | `starship init fish \| source` |
| zoxide | `zoxide init --cmd cd fish \| source` |
| atuin | `atuin init fish \| source` |
| direnv | `direnv hook fish \| source` |

## Machine-local additions

`local.star` is gitignored. Use it to add components that apply only to this machine:

```python
# local.star
component("@stdlib//components/slack")
component("@stdlib//components/zoom")
```

For fish shell overrides, edit `~/.config/fish/conf.d/99-local.fish` instead.

## Theme

All tools are hardcoded to **Catppuccin Mocha**. No dynamic theme switching.

## License

MIT — see individual component files for per-file authorship.
