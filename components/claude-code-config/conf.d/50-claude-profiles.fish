# components/claude-code-config/conf.d/50-claude-profiles.fish
#
# Two Claude Code account profiles. Each function gives the claude command one
# settings overlay through the --settings flag.
#
#   claude-personal (ccp)  the Anthropic account from `claude login`
#   claude-aws      (cca)  Amazon Bedrock, through AWS credentials
#
# The two accounts use separate credentials. Bedrock authenticates with AWS
# SigV4 through AWS_PROFILE. The personal account uses the OAuth token in
# ~/.claude.json. A switch changes the environment only. You do not log in
# again. Both accounts can run at the same time in different terminals.
#
# The claude-code-config component writes ~/.claude/profiles/aws.json from a
# template and prompts for the values. The dotmeow repository does not track
# that file, because the region and the profile name are machine-specific.

function claude-personal --wraps claude --description 'Claude Code with the personal Anthropic account'
    claude --settings $HOME/.claude/profiles/personal.json $argv
end

function claude-aws --wraps claude --description 'Claude Code through Amazon Bedrock'
    set -l overlay $HOME/.claude/profiles/aws.json
    if not test -f $overlay
        echo "claude-aws: $overlay does not exist." >&2
        echo "Run 'meowctl apply' and accept the Bedrock question to create it." >&2
        return 1
    end
    claude --settings $overlay $argv
end

abbr -a cca claude-aws
abbr -a ccp claude-personal
