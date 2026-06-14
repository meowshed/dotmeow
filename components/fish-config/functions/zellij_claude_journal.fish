function zellij_claude_journal --description "Launch Claude in ~/journal with project-root context when different"
    set -l project "$argv[1]"
    if test -z "$project"
        set project (command git rev-parse --show-toplevel 2>/dev/null)
        test -n "$project"; or set project "$PWD"
    end

    set -l journal ~/journal
    mkdir -p "$journal"; or return

    set -l project_real (command realpath "$project" 2>/dev/null)
    test -n "$project_real"; or set project_real "$project"

    set -l journal_real (command realpath "$journal" 2>/dev/null)
    test -n "$journal_real"; or set journal_real "$journal"

    cd "$journal_real"; or return

    if test "$project_real" = "$journal_real"
        exec claude
    end

    set -l prompt "This Claude Code session is running from the journal repo, which is the agentic harness/config workspace. The shell current working directory is: $journal_real. Use the journal repo's Claude Code configuration, instructions, commands, skills, hooks, and harness conventions normally. The active project open in Neovim/Zellij is a different directory. Its absolute path is: $project_real. Treat that absolute project path as the target codebase for code navigation, edits, build/test commands, and technical explanations. When referring to the current project, repo, or codebase, use: $project_real."

    exec claude --append-system-prompt "$prompt"
end
