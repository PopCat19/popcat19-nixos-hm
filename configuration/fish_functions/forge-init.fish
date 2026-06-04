# forge-init.fish
#
# Purpose: Initialize ForgeCode Fish integration — global state, key bindings, events
#
# This function:
# - Sets global variables for forge session state
# - Binds Enter and Tab to forge handlers
# - Configures right prompt for forge status
# - Sets up preexec/postexec hooks for terminal context
#
# Called automatically on fish startup via fish-functions.nix shellInit.
function forge-init
    # --- Global state variables ---
    if not set -q _forge_initialized
        set -g _forge_initialized true
        set -g _forge_conversation_id ""
        set -g _forge_active_agent "forge"
        set -g _forge_previous_conversation_id ""
        set -g _forge_session_model ""
        set -g _forge_session_provider ""
        set -g _forge_session_reasoning_effort ""

        # Key bindings
        bind \r forge-accept-line
        bind \t forge-tab

        set_color brblack
        echo "[forge] Fish integration loaded. Type : to send prompts."
        set_color normal
    end
end
