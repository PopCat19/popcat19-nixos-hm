# gtime.fish
#
# Purpose: Provide GNU time functionality in fish
#
# This function:
# - Runs GNU time when called
# - Used as alternative to fish's builtin time
function gtime
    command time $argv
end
