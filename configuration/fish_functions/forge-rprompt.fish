# forge-rprompt.fish
#
# Purpose: Display ForgeCode conversation and agent status in fish right prompt
#
# This function:
# - Shows active agent, session model, and conversation ID
# - Only displays when forge integration is active
function fish_right_prompt
    # Only show forge info if integration is active
    if not set -q _forge_initialized
        return
    end

    set -l parts

    # Active agent
    set -l agent "$_forge_active_agent"
    if test -n "$agent"
        set -a parts (set_color brblack)"󱙺 $agent"(set_color normal)
    end

    # Session model override
    if test -n "$_forge_session_model"
        set -a parts (set_color brblack)" $_forge_session_model"(set_color normal)
    end

    # Conversation ID (truncated)
    if test -n "$_forge_conversation_id"
        set -l short_id (string sub -l 8 -- "$_forge_conversation_id")
        set -a parts (set_color brblack)"#$short_id"(set_color normal)
    end

    if test (count $parts) -gt 0
        string join " " $parts
    end
end
