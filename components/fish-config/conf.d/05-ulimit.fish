# Increase file descriptor limit for heavy compilation and LSP servers.
# -S sets the soft limit only: plain `ulimit -n` also lowers the hard limit from
# launchd's unlimited to 10240, and entr (tmux-autoreload) then fails raising its
# soft limit to kern.maxfilesperproc.
ulimit -S -n 10240
