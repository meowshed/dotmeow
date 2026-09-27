# Set MISE_GITHUB_TOKEN from gh CLI so that mise makes authenticated GitHub API
# requests (avoids 60 req/hr anonymous rate limit).
#
# Not GITHUB_TOKEN: gh prefers that variable over its keyring login, so an
# exported copy shadows the login and `gh auth refresh` cannot take effect.
#
# Token is cached in ~/.cache/gh-token (mode 600) for 1 hour to avoid
# forking a gh subprocess on every pane open.
if command -q gh
    set -l cache $HOME/.cache/gh-token
    set -l token ""

    if test -f $cache
        set -l mtime (stat -f %m $cache 2>/dev/null)
        if test -n "$mtime"
            set -l age (math (date +%s) - $mtime)
            if test $age -lt 3600
                set token (cat $cache 2>/dev/null)
            end
        end
    end

    if test -z "$token"
        set token (gh auth token 2>/dev/null)
        if test -n "$token"
            mkdir -p (dirname $cache)
            printf '%s' $token > $cache
            chmod 600 $cache
        end
    end

    if test -n "$token"
        set -gx MISE_GITHUB_TOKEN $token
    end
end
