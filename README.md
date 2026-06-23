# dotmeow

A [meowctl](https://github.com/meowshed/meowctl) registry module that provides a complete, opinionated macOS development environment.

## What it installs

Dotmeow is a single component (`dotmeow.star`) that declares dependencies on the entire meow stack:

- **Shell:** fish, starship, zoxide, fzf, tmux
- **Dev tools:** neovim, vscode, docker, worktrunk, gpg
- **CLI utilities:** bat, eza, ripgrep, fd, btop, dust, duf, sd, jq, yq, dasel, miller, hyperfine, tokei, procs, xh, pandoc, ncdu, tealdeer, navi, gum, watchexec, direnv
- **Security:** age, openssl, mkcert, openssh
- **Media:** imagemagick, ffmpeg, vhs
- **Productivity:** typora, obsidian, drawio
- **macOS extras:** ghostty, hammerspoon, displayplacer
- **Config components:** fish-config, git-config, tmux-config, starship-config, bat-config, and 16 more custom configs

## Usage

In your personal dotfiles `init.star`:

```python
component("@dotmeow//dotmeow")
```

Or add via CLI:

```sh
meowctl dep add dotmeow
meowctl apply
```

## Module structure

```
dotmeow.star    # the single component with all after= dependencies
components/     # custom config components (fish-config, git-config, etc.)
MODULE.meow     # module identity + registry deps (stdlib)
```

## Dependencies

| Module | Version | Purpose |
|--------|---------|---------|
| stdlib | ^0.1.14 | Package managers, bundles, base tools |
| sesh | via stdlib | Smart tmux session manager |

## License

MIT
