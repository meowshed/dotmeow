# Set GITHUB_TOKEN from gh CLI so that mise and other tools can make
# authenticated GitHub API requests (avoids 60 req/hr anonymous rate limit).
if command -q gh
    set -gx GITHUB_TOKEN (gh auth token 2>/dev/null)
end
