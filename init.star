# dotmeow.star
#
# platform: all
# after:    (see below)
#
# The single dotmeow component — declares all shared dependencies
# and custom config components. No install hook needed; all work is
# done by dependencies and child components.
#
# Opt-in components live in components/ but are intentionally absent from the
# `after` list below, so they install only when a machine asks for them:
#
#   kubernetes — kubectl, kubectx, stern, helm, k9s
#                component("@dotmeow//components/kubernetes") in local.star

after = [
    # --- stdlib tools ---
    "@stdlib//components/tmux",
    "@stdlib//components/sesh",
    "@stdlib//components/brew",
    "@stdlib//components/mise",
    "@stdlib//bundles/modern-shell",
    "@stdlib//bundles/modern-macos",
    "@stdlib//bundles/github",
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
    "@stdlib//components/tree_sitter",
    "@stdlib//components/copilot_language_server",
    "@stdlib//components/claude-code",
    "@stdlib//components/claude-desktop",
    "@stdlib//components/fonts",
    "@stdlib//components/watch",

    # --- shell + file navigation ---
    "@stdlib//components/yazi",
    "@stdlib//components/usage",
    "@stdlib//components/jless",
    "@stdlib//components/hexyl",
    "@stdlib//components/ouch",
    "@stdlib//components/lnav",
    "@stdlib//components/duckdb",
    "@stdlib//components/mprocs",

    # --- version control ---
    "@stdlib//components/difftastic",
    "@stdlib//components/jj",

    # --- containers ---
    "@stdlib//components/lazydocker",
    "@stdlib//components/dive",

    # --- secrets ---
    "@stdlib//components/sops",

    # --- network + media ---
    "@stdlib//components/gping",
    "@stdlib//components/bandwhich",
    "@stdlib//components/yt_dlp",

    # --- screen recording ---
    "@stdlib//components/keycastr",

    # --- menu bar ---
    "@stdlib//components/ice",

    # --- custom config components ---
    "fish-config",
    "git-config",
    "ssh-config",
    "gh-config",
    "meowvim",
    "tmux-config",
    "starship-config",
    "bat-config",
    "ghostty-config",
    "claude-code-config",
    "lazygit-config",
    "eza-config",
    "glow-config",
    "ripgrep-config",
    "btop-config",
    "tealdeer-config",
    "fzf-config",
    "macos-defaults",
    "capslock-control",
]
