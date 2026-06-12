# grep.fish
#
# Purpose: Wrap grep to remind about ripgrep when rg is installed
#
# rg replaces all grep usage and is significantly faster for
# recursive text search. This wrapper prints a reminder to stderr
# then delegates to the real grep.
function grep --wraps grep
    if command -q rg
        echo "💡 rg is faster — try: rg $argv" >&2
    end
    command grep --color=auto $argv
end
