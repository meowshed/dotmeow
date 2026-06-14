function clip --description 'Copy stdin, argument text, or file contents to the macOS clipboard'
    if not command -q pbcopy
        echo 'pbcopy is required' >&2
        return 1
    end

    if not isatty stdin
        pbcopy
        return $status
    end

    if test (count $argv) -eq 0
        if command -q pbpaste
            pbpaste
            return $status
        end
        return 1
    end

    if test (count $argv) -eq 1
        and test -f "$argv[1]"
        command cat "$argv[1]" | pbcopy
    else
        string join ' ' -- $argv | pbcopy
    end
end
