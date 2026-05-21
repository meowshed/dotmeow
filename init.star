# init.star — dotmeow configuration
#
# Reference dotfiles for the meow stack.
# https://github.com/meowshed/dotmeow
#
# Module deps are declared in deps.mod. @stdlib resolves to meowshed/meowctl-stdlib.

# --- stdlib tools ---

component("@stdlib//components/brew")       # macOS: bootstrap Homebrew
component("@stdlib//components/mise")       # tool version manager
component("@stdlib//bundles/modern-shell")  # fish, neovim, zellij, starship, atuin + more
component("@stdlib//bundles/modern-macos")  # ghostty, fonts, keka, maccy, caffeine + more
component("@stdlib//bundles/github")        # git, lazygit, delta, forgit, gh, git_lfs, act
component("@stdlib//components/hammerspoon")  # macOS automation framework
component("hammerspoon-config")               # link ~/.hammerspoon/init.lua (pulls adaptive-keyboard-layouts, meowvim-keyboard-layouts)

# --- custom config components ---

component("fish-config")                # link config.fish into ~/.config/fish/
component("git-config")                 # link ~/.config/git/config; prompt for identity on first install
component("ssh-config")                 # link ~/.ssh/config; ControlMaster, AddKeysToAgent, UseKeychain
component("atuin-config")               # link atuin config; Catppuccin Mocha, inline mode, sync off
component("gh-config")                  # link gh config; hosts.yml managed by gh auth login
component("meowvim")                    # clone retran/meowvim into ~/.config/nvim
component("zellij-config")             # link zellij config files into ~/.config/zellij/
component("starship-config")           # link starship.toml into ~/.config/starship.toml
component("bat-config")                # link bat config into ~/.config/bat/
component("ghostty-config")            # link ghostty config into ~/.config/ghostty/
component("lazygit-config")            # link lazygit config into ~/.config/lazygit/
component("eza-config")                # link eza config and theme into ~/.config/eza/
component("glow-config")               # link glow config into ~/.config/glow/
component("ripgrep-config")            # link ripgrep config into ~/.config/ripgrep/
component("btop-config")               # link btop config and theme into ~/.config/btop/
component("tealdeer-config")           # link tealdeer config into ~/.config/tealdeer/
component("fzf-config")                # set FZF_DEFAULT_OPTS (Catppuccin Mocha) + per-binding opts

# --- standalone meowctl modules (resolved from deps.mod) ---
# adaptive-keyboard-layouts  — meowshed/adaptive-keyboard-layouts
# zjstatus-widgets           — meowshed/zjstatus-widgets
# meowvim-keyboard-layouts   — meowshed/meowvim-keyboard-layouts

# --- macOS desktop extras ---

component("@stdlib//components/displayplacer")  # CLI display placement tool

# --- image / media tools ---

component("@stdlib//components/imagemagick")  # image processing CLI
component("@stdlib//components/ffmpeg")       # audio/video processing toolkit
component("@stdlib//components/vhs")          # terminal GIF recorder

# --- writing / docs ---

component("@stdlib//components/typora")   # Markdown editor
component("@stdlib//components/obsidian") # knowledge base

# --- dev tools ---

component("@stdlib//components/vscode")    # Visual Studio Code
component("@stdlib//components/orbstack")   # Docker and Linux VMs
component("@stdlib//components/docker_cli") # Docker CLI (explicit, orbstack provides daemon)
component("@stdlib//components/worktrunk")  # git worktree manager
component("@stdlib//components/gpg")        # GPG encryption and signing
component("@stdlib//components/hyperfine")  # CLI benchmarking tool
component("@stdlib//components/tokei")      # code statistics (LOC, comments, blanks)
component("@stdlib//components/procs")      # modern ps replacement
component("@stdlib//components/xh")         # modern HTTP client (httpie alternative)
component("@stdlib//components/pandoc")     # document conversion
component("@stdlib//components/ncdu")       # ncurses disk usage viewer
component("@stdlib//components/drawio")     # diagramming tool
