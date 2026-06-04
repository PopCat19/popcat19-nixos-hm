# forge-tab.fish
#
# Purpose: Intercept Tab key for ForgeCode command completion and @file tagging
#
# This function:
# - Handles Tab when cursor is on a :command prefix (fuzzy command selection)
# - Handles Tab when cursor is on @partial_file (fuzzy file picker)
# - Delegates to normal Fish completion otherwise
function forge-tab
    set -l buf (commandline)

    # Check if we're at a @partial_file token
    set -l tok (commandline -t)
    if string match -qr '^@' -- "$tok"
        set -l filter (string replace -r '^@' '' -- "$tok")
        set -l selected (CLICOLOR_FORCE=0 forge select file --query "$filter" </dev/tty 2>/dev/tty)
        if test -n "$selected"
            # Replace the @token with @[filepath]
            set -l full "@[$selected]"
            set -l pos (commandline -P)
            set -l before_pos (math $pos - (string length "$tok") + 1)
            if test $before_pos -lt 1
                set before_pos 1
            end
            set -l prefix (string sub -l (math $before_pos - 1) -- "$buf")
            set -l suffix (string sub -s (math $pos + 1) -- "$buf")
            set -l newbuf "$prefix$full$suffix"
            commandline -r "$newbuf"
            commandline -C (math $before_pos + (string length "$full"))
            commandline -f repaint
        end
        return 0
    end

    # Check if buffer starts with : and cursor is on the command word (no space after :)
    if string match -qr '^:([a-zA-Z][a-zA-Z0-9_-]*)?$' -- "$buf"
        set -l filter (string replace -r '^:' '' -- "$buf")
        set -l selected (CLICOLOR_FORCE=0 forge select command --query "$filter" </dev/tty 2>/dev/tty)
        if test -n "$selected"
            commandline -r ":$selected "
            commandline -C (string length ":$selected ")  # cursor after space
            commandline -f repaint
        end
        return 0
    end

    # Not a forge-specific completion — delegate to normal Fish completion
    commandline -f complete
end
