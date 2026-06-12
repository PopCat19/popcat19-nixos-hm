# find.fish
#
# Purpose: Wrap find to remind about ripgrep for -name patterns
#
# rg --files -g '<glob>' replaces find -name. Other find predicates
# (-type, -mtime, -exec, -delete) have no rg equivalent and pass
# through silently.
function find --wraps find
    if command -q rg
        if string match -qr -- '-(i)?name' $argv
            echo "💡 rg --files -g '<glob>' is faster than find -name" >&2
        end
    end
    command find $argv
end
