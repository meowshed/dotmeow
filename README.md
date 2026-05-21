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
components/        # local component .star files + assets
hooks/             # extension hooks for stdlib components + assets
```

## Components

| Component | Description |
|-----------|-------------|
| `@stdlib//components/brew` | Homebrew (macOS) |
| `@stdlib//components/mise` | Tool version manager |
| `@stdlib//components/zsh` | Zsh shell |
| `@stdlib//components/neovim` | Neovim editor |
| `@stdlib//components/zellij` | Terminal multiplexer |
| `@stdlib//components/starship` | Shell prompt |
| `@stdlib//components/atuin` | Shell history |
| `meowvim` | Clone [retran/meowvim](https://github.com/retran/meowvim) into `~/.config/nvim` |
| `zellij-config` | Link zellij config and layouts into `~/.config/zellij/` |
| `starship-config` | Link `starship.toml` into `~/.config/starship.toml` |

## Extension Hooks

| Hook | Extends | What it does |
|------|---------|--------------|
| `hooks/zsh.star` | `@stdlib//components/zsh` | Links `.zshrc` from `hooks/zsh/.zshrc` |
| `hooks/neovim.star` | `@stdlib//components/neovim` | Logs reminder to sync lazy.nvim plugins |

## Machine-local additions

`local.star` is gitignored. Use it to add components that apply only to this machine:

```python
# local.star
component("@stdlib//components/slack")
component("@stdlib//components/zoom")
```

## Shell integration

Add to `~/.zshrc` (or let the `hooks/zsh.star` extension hook manage it):

```sh
eval "$(meowctl shell zsh)"
```
