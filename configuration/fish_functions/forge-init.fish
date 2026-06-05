# forge-init.fish
#
# Purpose: Initialize ForgeCode Fish integration — global state, key bindings, events
#
# This function:
# - Sets global variables for forge session state
# - Binds Enter and Tab to forge handlers
# - Sets up FORGE_TERM terminal context tracking (command history for agent awareness)
# - Registers fish_preexec/fish_postexec event handlers
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

        # FORGE_TERM: terminal context tracking (on by default)
        # Tracks recently-run shell commands so ForgeCode knows what you ran
        # and what failed without you explaining. Disable with FORGE_TERM=false.
        set -g _forge_term_enabled true
        if test "$FORGE_TERM" = "false"
            set -g _forge_term_enabled false
        end
        set -g _forge_term_max_commands 5
        if test -n "$FORGE_TERM_MAX_COMMANDS"
            set -g _forge_term_max_commands "$FORGE_TERM_MAX_COMMANDS"
        end
        set -g _forge_term_commands
        set -g _forge_term_exit_codes
        set -g _forge_term_timestamps

        # Key bindings
        bind \r forge-accept-line
        bind \t forge-tab

        set_color brblack
        echo "[forge] Fish integration loaded. Type : to send prompts."
        if test "$_forge_term_enabled" = "true"
            echo "[forge] Terminal context tracking ON (FORGE_TERM)"
        end
        set_color normal
    end
end

# --- FORGE_TERM: preexec hook — captures command before execution ---
function _forge_context_preexec --on-event fish_preexec
    if test "$_forge_term_enabled" != "true"
        return
    end
    set -g _forge_term_pending_cmd "$argv"
    set -g _forge_term_pending_ts (date +%s)
end

# --- FORGE_TERM: postexec hook — captures exit code after execution ---
function _forge_context_postexec --on-event fish_postexec
    set -l last_exit $status
    if test "$_forge_term_enabled" != "true"
        return
    end
    if test -n "$_forge_term_pending_cmd"
        set -a _forge_term_commands "$_forge_term_pending_cmd"
        set -a _forge_term_exit_codes "$last_exit"
        set -a _forge_term_timestamps "$_forge_term_pending_ts"

        # Trim buffer to max_commands
        while test (count $_forge_term_commands) -gt $_forge_term_max_commands
            set -e _forge_term_commands[1]
            set -e _forge_term_exit_codes[1]
            set -e _forge_term_timestamps[1]
        end

        set -ge _forge_term_pending_cmd
        set -ge _forge_term_pending_ts
    end
end
