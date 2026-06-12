# rg-remind.fish
#
# Purpose: Remind user to use ripgrep (rg) instead of grep/find -name
#
# rg is significantly faster for recursive text search and file-name
# matching. This function prints a reminder to stderr when rg is
# installed, then delegates to the real command.
#
# Scope: grep is fully replaceable by rg. find -name is replaceable
# by rg --files -g. find -type/-mtime/-exec/-delete have no rg equivalent
# and are not reminded.
function grep --wraps grep
    if command -q rg
        echo "💡 rg is faster — try: rg $argv" >&2
    end
    command grep $argv
end

function find --wraps find
    if command -q rg
        # Only remind for -name/-iname patterns (rg-replaceable).
        # find -type/-mtime/-exec/-delete have no rg equivalent.
        if string match -qr -- '-(i)?name' $argv
            echo "💡 rg --files -g '<glob>' is faster than find -name" >&2
        end
    end
    command find $argv
end
