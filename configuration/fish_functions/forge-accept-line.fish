# forge-accept-line.fish
#
# Purpose: Intercept Enter key to dispatch : sentinel commands to ForgeCode
#
# This function:
# - Checks if the command buffer starts with : (ForgeCode sentinel)
# - Dispatches :command and : prompt syntax to forge CLI
# - Delegates to normal shell execution for non-: commands
# - Shares state with forge-init.fish global variables
function forge-accept-line
    set -l buf (commandline)

    # Only intercept if buffer starts with :
    if not string match -qr '^:' -- $buf
        commandline -f execute
        return
    end

    # Parse :command <rest> or : <prompt>
    set -l user_action ""
    set -l input_text ""

    if string match -qr '^:([a-zA-Z][a-zA-Z0-9_-]*)( (.*))?$' -- $buf
        set -l match1 (string replace -r '^:([a-zA-Z][a-zA-Z0-9_-]*)( (.*))?$' '$1' -- $buf)
        set -l match3 (string replace -r '^:([a-zA-Z][a-zA-Z0-9_-]*)( (.*))?$' '$3' -- $buf)
        set user_action "$match1"
        if test -n "$match3"
            set input_text "$match3"
        end
    else if string match -qr '^: (.*)$' -- $buf
        set input_text (string replace -r '^: (.*)$' '$1' -- $buf)
    else
        # Just : alone or only whitespace after : — list commands
        forge-accept-line-dispatch "command-list" ""
        commandline -r ""
        commandline -f repaint
        return
    end

    # Save to history
    set -l hist_buf "$buf"

    # Clear the buffer immediately
    commandline -r ""
    commandline -f repaint

    # Dispatch based on first word after :
    forge-accept-line-dispatch "$user_action" "$input_text"
end

# --- Internal dispatch function ---
function forge-accept-line-dispatch
    set -l action "$argv[1]"
    set -l text "$argv[2]"

    # Normalize aliases (short forms from Zsh plugin)
    switch "$action"
        case ask
            set action sage
        case plan
            set action muse
        case a
            set action agent
        case c
            set action conversation
        case cm
            set action config-model
        case m
            set action model
        case cr mr config-reload model-reset
            set action config-reload
        case re
            set action reasoning-effort
        case cre
            set action config-reasoning-effort
        case ccm
            set action config-commit-model
        case csm
            set action config-suggest-model
        case t
            set action tools
        case e env
            set action config
        case ce
            set action config-edit
        case ed
            set action edit
        case r
            set action retry
        case s
            set action suggest
        case rn
            set action rename
        case i
            set action info
        case d
            set action dump
        case n
            set action new
        case sync workspace-sync
            set action workspace-sync
        case sync-init workspace-init
            set action workspace-init
        case sync-status workspace-status
            set action workspace-status
        case sync-info workspace-info
            set action workspace-info
        case login provider login provider-login
            set action provider-login
    end

    switch "$action"
        # --- Commands that don't need a conversation ---
        case agent
            if test -n "$text"
                # :agent <name> — switch directly
                if forge list agents --porcelain 2>/dev/null | tail -n +2 | grep -q "^$text\b"
                    set -g _forge_active_agent "$text"
                    echo
                    set_color green
                    echo "[SUCCESS] Switched to agent $text"
                    set_color normal
                else
                    echo
                    set_color red
                    echo "[ERROR] Agent '$text' not found"
                    set_color normal
                end
            else
                # :agent — interactive picker
                set -l selected (CLICOLOR_FORCE=0 forge select agent </dev/tty 2>/dev/tty)
                if test -n "$selected"
                    set -g _forge_active_agent "$selected"
                    echo
                    set_color green
                    echo "[SUCCESS] Switched to agent $selected"
                    set_color normal
                end
            end

        case model session-model
            echo
            set -l selected (CLICOLOR_FORCE=0 forge select model --provider-all </dev/tty 2>/dev/tty)
            if test -n "$selected"
                set -g _forge_session_model "$selected"
                set_color green
                echo "[SUCCESS] Session model set to $selected"
                set_color normal
            end

        case config-model
            echo
            set -l selected (CLICOLOR_FORCE=0 forge select model --provider-all </dev/tty 2>/dev/tty)
            if test -n "$selected"
                forge config set model "$selected"
            end

        case config-commit-model
            echo
            set -l selected (CLICOLOR_FORCE=0 forge select model </dev/tty 2>/dev/tty)
            if test -n "$selected"
                forge config set commit "$selected"
            end

        case config-suggest-model
            echo
            set -l selected (CLICOLOR_FORCE=0 forge select model </dev/tty 2>/dev/tty)
            if test -n "$selected"
                forge config set suggest "$selected"
            end

        case config-reload
            echo
            if test -z "$_forge_session_model" -a -z "$_forge_session_provider"
                set_color yellow
                echo "[INFO] No session overrides active (already using global config)"
                set_color normal
            else
                set -ge _forge_session_model
                set -ge _forge_session_provider
                set_color green
                echo "[SUCCESS] Session overrides cleared — using global config"
                set_color normal
            end

        case reasoning-effort
            echo
            set -l selected (CLICOLOR_FORCE=0 forge select reasoning-effort </dev/tty 2>/dev/tty)
            if test -n "$selected"
                set -g _forge_session_reasoning_effort "$selected"
                set_color green
                echo "[SUCCESS] Session reasoning effort set to $selected"
                set_color normal
            end

        case config-reasoning-effort
            echo
            set -l selected (CLICOLOR_FORCE=0 forge select reasoning-effort </dev/tty 2>/dev/tty)
            if test -n "$selected"
                forge config set reasoning-effort "$selected"
            end

        case config
            echo
            forge config list

        case config-edit
            echo
            set -l editor_cmd
            if test -n "$FORGE_EDITOR"
                set editor_cmd "$FORGE_EDITOR"
            else if test -n "$EDITOR"
                set editor_cmd "$EDITOR"
            else
                set editor_cmd "nano"
            end
            set -l config_file (forge config path 2>/dev/null)
            if test -z "$config_file"
                set_color red
                echo "[ERROR] Failed to resolve config path"
                set_color normal
                return 1
            end
            mkdir -p (dirname "$config_file")
            eval "$editor_cmd '$config_file'" </dev/tty >/dev/tty 2>&1
            set -l exit_code $status
            if test $exit_code -ne 0
                set_color red
                echo "[ERROR] Editor exited with code $exit_code"
                set_color normal
            end

        case tools
            echo
            forge list tools "$_forge_active_agent"

        case skill
            echo
            forge list skill

        case suggest
            if test -z "$text"
                echo
                set_color yellow
                echo "[INFO] Usage: :suggest <natural language description>"
                set_color normal
                return
            end
            echo
            set -l result (FORCE_COLOR=true CLICOLOR_FORCE=1 forge suggest "$text")
            if test -n "$result"
                # Place the suggested command in the buffer for user review
                commandline -r "$result"
                commandline -f repaint
            end

        case commit
            echo
            set -l msg (forge commit --preview 2>/dev/null)
            if test -n "$msg"
                if git diff --staged --quiet 2>/dev/null
                    commandline -r "git commit -am '$msg'"
                else
                    commandline -r "git commit -m '$msg'"
                end
                commandline -f repaint
            end

        case info
            echo
            forge info --cid "$_forge_conversation_id" 2>/dev/null
            or forge info

        case dump
            echo
            if test -n "$text"
                forge conversation dump $_forge_conversation_id $text
            else
                forge conversation dump $_forge_conversation_id
            end

        case compact
            echo
            forge conversation compact $_forge_conversation_id

        case rename
            echo
            if test -n "$text"
                forge conversation rename $_forge_conversation_id $text
            end

        case conversation
            echo
            if test "$text" = "-"
                # Switch to previous conversation
                if test -n "$_forge_previous_conversation_id"
                    set -l tmp "$_forge_conversation_id"
                    set -g _forge_conversation_id "$_forge_previous_conversation_id"
                    set -g _forge_previous_conversation_id "$tmp"
                    forge conversation show $_forge_conversation_id
                    forge conversation info $_forge_conversation_id
                    set_color green
                    echo "[SUCCESS] Switched to conversation $_forge_conversation_id"
                    set_color normal
                else
                    set_color yellow
                    echo "[INFO] No previous conversation to switch to"
                    set_color normal
                end
            else if test -n "$text"
                # Switch to specific conversation ID
                forge conversation show "$text" 2>/dev/null
                if test $status -eq 0
                    set -g _forge_previous_conversation_id "$_forge_conversation_id"
                    set -g _forge_conversation_id "$text"
                    forge conversation info "$text"
                    set_color green
                    echo "[SUCCESS] Switched to conversation $text"
                    set_color normal
                else
                    set_color red
                    echo "[ERROR] Conversation '$text' not found"
                    set_color normal
                end
            else
                # Interactive conversation picker
                set -l selected (CLICOLOR_FORCE=0 forge select conversation </dev/tty 2>/dev/tty)
                if test -n "$selected"
                    forge conversation show "$selected"
                    forge conversation info "$selected"
                    set -g _forge_previous_conversation_id "$_forge_conversation_id"
                    set -g _forge_conversation_id "$selected"
                    set_color green
                    echo "[SUCCESS] Switched to conversation $selected"
                    set_color normal
                end
            end

        case new
            echo
            if test -n "$_forge_conversation_id"
                set -g _forge_previous_conversation_id "$_forge_conversation_id"
            end
            set -g _forge_conversation_id ""
            if test -n "$text"
                # Start new conversation AND send prompt
                set -l new_id (forge conversation new)
                set -g _forge_conversation_id "$new_id"
                forge --prompt "$text" --agent "$_forge_active_agent" --cid "$new_id" </dev/tty >/dev/tty
            end
            set_color green
            echo "[SUCCESS] Started new conversation"
            set_color normal

        case retry
            echo
            echo "[INFO] Retry not yet implemented — resend your : prompt"
            set_color yellow
            # TODO: store last prompt for retry

        case edit
            echo
            set -l editor_cmd
            if test -n "$FORGE_EDITOR"
                set editor_cmd "$FORGE_EDITOR"
            else if test -n "$EDITOR"
                set editor_cmd "$EDITOR"
            else
                set editor_cmd "nano"
            end
            set -l tmpfile (mktemp)
            if test -n "$text"
                echo "$text" >"$tmpfile"
            end
            eval "$editor_cmd '$tmpfile'" </dev/tty >/dev/tty 2>&1
            set -l exit_code $status
            if test $exit_code -ne 0
                set_color red
                echo "[ERROR] Editor exited with code $exit_code"
                set_color normal
            end
            command rm -f "$tmpfile"
            if test -f "$tmpfile.save"
                set text (cat "$tmpfile.save" 2>/dev/null)
                command rm -f "$tmpfile.save"
            end
            if test -n "$text"
                forge-accept-line-dispatch "" "$text"
            end

        case provider-login
            echo
            set -l provider "$text"
            if test -z "$provider"
                set provider (CLICOLOR_FORCE=0 forge select provider </dev/tty 2>/dev/tty)
            end
            if test -n "$provider"
                forge provider login "$provider" </dev/tty >/dev/tty
            end

        case logout
            echo
            set -l provider "$text"
            if test -z "$provider"
                set provider (CLICOLOR_FORCE=0 forge select provider --configured </dev/tty 2>/dev/tty)
            end
            if test -n "$provider"
                forge provider logout "$provider"
            end

        case workspace-sync
            echo
            forge workspace sync --init </dev/tty >/dev/tty

        case workspace-init
            echo
            forge workspace init </dev/tty >/dev/tty

        case workspace-status
            echo
            forge workspace status "."

        case workspace-info
            echo
            forge workspace info "."

        case help
            echo
            forge-accept-line-show-help
            commandline -r ""
            commandline -f repaint

        case command-list
            echo
            forge-accept-line-show-help
            commandline -r ""
            commandline -f repaint

        case copy
            echo
            if test -n "$_forge_conversation_id"
                echo -n "$_forge_conversation_id" | commandline -r ""
                # Use clip if available, else xclip
                if command -q wl-copy 2>/dev/null
                    echo -n "$_forge_conversation_id" | wl-copy
                else if command -q xclip 2>/dev/null
                    echo -n "$_forge_conversation_id" | xclip -selection clipboard
                end
                set_color green
                echo "[SUCCESS] Conversation ID copied: $_forge_conversation_id"
                set_color normal
            else
                set_color yellow
                echo "[INFO] No active conversation"
                set_color normal
            end

        case '' # Empty action = default prompt
            if test -z "$text"
                return 0
            end
            if test -z "$_forge_conversation_id"
                set -l new_id (forge conversation new)
                set -g _forge_conversation_id "$new_id"
            end
            echo
            # Build and execute forge command
            forge-accept-line-exec-prompt "$text"

        case '*'
            # Check if it's a known command or an agent name
            if test -z "$text"
                # No input text — might be an agent name
                set -l agent_exists (forge list agents --porcelain 2>/dev/null | tail -n +2 | grep -q "^$action\b"; and echo "true"; or echo "false")
                if test "$agent_exists" = "true"
                    set -g _forge_active_agent "$action"
                    echo
                    set_color green
                    echo "[SUCCESS] $action is now the active agent"
                    set_color normal
                    return 0
                end
                set_color red
                echo "[ERROR] Command '$action' not found. Type : to see available commands."
                set_color normal
                return 1
            end
            # Has input text — treat as agent name with prompt
            set -l agent_exists (forge list agents --porcelain 2>/dev/null | tail -n +2 | grep -q "^$action\b"; and echo "true"; or echo "false")
            if test "$agent_exists" = "true"
                set -g _forge_active_agent "$action"
                if test -z "$_forge_conversation_id"
                    set -l new_id (forge conversation new)
                    set -g _forge_conversation_id "$new_id"
                end
                echo
                forge-accept-line-exec-prompt "$text"
            else
                # Not an agent — check custom commands
                forge-accept-line-exec-custom "$action" "$text"
            end
    end
end

# --- Execute a prompt (default mode) ---
function forge-accept-line-exec-prompt
    set -l text "$argv[1]"
    set -l agent "$_forge_active_agent"
    if test -z "$agent"
        set agent "forge"
    end

    # Pass terminal context (FORGE_TERM) as env vars so the agent knows
    # what commands you ran and what failed — matches Zsh plugin convention.
    set -l term_env
    if test "$_forge_term_enabled" = "true" -a (count $_forge_term_commands) -gt 0
        set -l sep \x1f
        set -l cmds (string join "$sep" $_forge_term_commands)
        set -l codes (string join "$sep" $_forge_term_exit_codes)
        set -l stamps (string join "$sep" $_forge_term_timestamps)
        set term_env _FORGE_TERM_COMMANDS="$cmds" _FORGE_TERM_EXIT_CODES="$codes" _FORGE_TERM_TIMESTAMPS="$stamps"
    end

    set -l extra_env
    if test -n "$_forge_session_model"
        set -a extra_env FORGE_SESSION__MODEL_ID="$_forge_session_model"
    end
    if test -n "$_forge_session_provider"
        set -a extra_env FORGE_SESSION__PROVIDER_ID="$_forge_session_provider"
    end
    if test -n "$_forge_session_reasoning_effort"
        set -a extra_env FORGE_REASONING__EFFORT="$_forge_session_reasoning_effort"
    end

    set -l cmd forge --agent "$agent" --prompt "$text" --cid "$_forge_conversation_id"
    # Run with env vars if present
    if test (count $term_env) -gt 0 -o (count $extra_env) -gt 0
        env $term_env $extra_env $cmd </dev/tty >/dev/tty
    else
        $cmd </dev/tty >/dev/tty
    end
end

# --- Execute a custom command ---
function forge-accept-line-exec-custom
    set -l cmd_name "$argv[1]"
    set -l cmd_text "$argv[2]"

    if test -z "$_forge_conversation_id"
        set -l new_id (forge conversation new)
        set -g _forge_conversation_id "$new_id"
    end

    echo
    if test -n "$cmd_text"
        forge cmd execute --cid "$_forge_conversation_id" "$cmd_name" "$cmd_text" </dev/tty >/dev/tty
    else
        forge cmd execute --cid "$_forge_conversation_id" "$cmd_name" </dev/tty >/dev/tty
    end
end

# --- Show help ---
function forge-accept-line-show-help
    echo
    set_color brwhite
    echo "ForgeCode Commands"
    set_color normal
    echo "────────────────────────────"
    echo
    set_color cyan; echo "  : <prompt>"; set_color normal
    echo "      Send a prompt to ForgeCode"
    echo
    set_color cyan; echo "  :new [prompt]"; set_color normal
    echo "      Start a fresh conversation (optionally with prompt)"
    echo
    set_color cyan; echo "  :agent [name]"; set_color normal
    echo "      Switch active agent (or pick from list)"
    echo
    set_color cyan; echo "  :conversation [id|-]"; set_color normal
    echo "      Switch conversation (use - for previous)"
    echo
    set_color cyan; echo "  :model"; set_color normal
    echo "      Set session model override"
    echo
    set_color cyan; echo "  :edit [prompt]"; set_color normal
    echo "      Compose prompt in editor (\$EDITOR)"
    echo
    set_color cyan; echo "  :suggest <task>"; set_color normal
    echo "      Suggest shell command from natural language"
    echo
    set_color cyan; echo "  :commit"; set_color normal
    echo "      Generate and preview commit message"
    echo
    set_color cyan; echo "  :config / :config-edit / :config-reload"; set_color normal
    echo "      Manage ForgeCode configuration"
    echo
    set_color cyan; echo "  :login / :logout"; set_color normal
    echo "      Manage AI provider authentication"
    echo
    set_color cyan; echo "  :tools / :skill / :info"; set_color normal
    echo "      Show available tools, skills, or session info"
    echo
    set_color cyan; echo "  :workspace-sync / :workspace-status"; set_color normal
    echo "      Manage codebase workspace for semantic search"
    echo
    echo "────────────────────────────"
    set_color brblack
    echo "Type :<TAB> to fuzzy-search commands"
    set_color normal
end
