# proxify.fish (completion)
#
# Purpose: Provide completions for proxify command
#
# This completion:
# - Suggests available commands
# - Suggests fish functions
# - Suggests aliases

function __proxify_complete
    command -a
    functions
    alias | string replace -r 'alias (.+)=.*' '$1'
end

complete -c proxify -f -a "(__proxify_complete)"
