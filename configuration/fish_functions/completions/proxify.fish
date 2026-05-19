# proxify.fish (completion)
#
# Purpose: Provide completions for proxify command
#
# Uses sing-box TUN for system-wide proxy; proxify is a per-app launcher
# for Chromium browsers with explicit SOCKS5 proxy flags.

function __proxify_complete
    command -a
    functions
    alias | string replace -r 'alias (.+)=.*' '$1'
end

complete -c proxify -f -a "(__proxify_complete)"
