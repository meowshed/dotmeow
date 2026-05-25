# dotmeow.star
#
# platform: all
# after:    (see below)
#
# The single dotmeow component — declares all shared dependencies
# and custom config components. No install hook needed; all work is
# done by dependencies and child components.

after = [
    # --- stdlib tools ---
    "@stdlib//components/brew",
    "@stdlib//components/mise",
    "@stdlib//bundles/modern-shell",
    "@stdlib//bundles/modern-macos",
    "@stdlib//bundles/github",
    "@stdlib//components/hammerspoon",
    "@stdlib//components/displayplacer",
    "@stdlib//components/imagemagick",
    "@stdlib//components/ffmpeg",
    "@stdlib//components/vhs",
    "@stdlib//components/typora",
    "@stdlib//components/obsidian",
    "@stdlib//components/vscode",
    "@stdlib//components/docker_cli",
    "@stdlib//components/worktrunk",
    "@stdlib//components/gpg",
    "@stdlib//components/hyperfine",
    "@stdlib//components/tokei",
    "@stdlib//components/procs",
    "@stdlib//components/xh",
    "@stdlib//components/pandoc",
    "@stdlib//components/ncdu",
    "@stdlib//components/drawio",

    # --- custom config components ---
    "fish-config",
    "git-config",
    "ssh-config",
    "atuin-config",
    "gh-config",
    "meowvim",
    "zellij-config",
    "starship-config",
    "bat-config",
    "ghostty-config",
    "lazygit-config",
    "eza-config",
    "glow-config",
    "ripgrep-config",
    "btop-config",
    "tealdeer-config",
    "fzf-config",
    "hammerspoon-config",
]
