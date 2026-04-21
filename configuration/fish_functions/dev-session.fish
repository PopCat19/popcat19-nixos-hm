# dev-session.fish
#
# Purpose: Launch tmux development session with predefined layout
#
# This function:
# - Creates a tmux session with 4 windows
# - Sets up split panes with btop and journalctl
# - Launches sillytavern and zrok share
# - Attaches to session or creates new one

function dev-session
    set -l session_name "dev"

    # Check if session already exists
    if tmux has-session -t $session_name 2>/dev/null
        set_color yellow; echo "[INFO] Session '$session_name' already exists"; set_color normal
        set_color cyan; echo "[INFO] Attaching to existing session..."; set_color normal
        tmux attach -t $session_name
        return 0
    end

    set_color blue; echo "[STEP] Creating tmux session: $session_name"; set_color normal

    # Window 1: System monitoring (btop + journalctl)
    # Create session with first window named "monitor"
    tmux new-session -d -s $session_name -n monitor

    # Split window horizontally (creates top/bottom)
    # Top pane (80%): btop
    tmux split-window -v -p 20 -t $session_name:monitor
    tmux send-keys -t $session_name:monitor.0 'btop' Enter
    # Bottom pane (20%): journalctl -f
    tmux send-keys -t $session_name:monitor.1 'journalctl -f' Enter

    # Window 2: SillyTavern
    tmux new-window -t $session_name -n sillytavern
    tmux send-keys -t $session_name:sillytavern 'sillytavern' Enter

    # Window 3: Zrok share
    # Requires: agenix secret "zrok-share-token" configured in NixOS
    tmux new-window -t $session_name -n zrok
    set -l zrok_token (cat /run/agenix/zrok-share-token 2>/dev/null; or echo "")
    if test -n "$zrok_token"
        tmux send-keys -t $session_name:zrok "zrok share reserved $zrok_token" Enter
    else
        # Show error in the zrok window itself
        tmux send-keys -t $session_name:zrok 'echo "ERROR: Zrok share token not found at /run/agenix/zrok-share-token"' Enter
        tmux send-keys -t $session_name:zrok 'echo "Ensure agenix is configured and the secret is decrypted"' Enter
    end

    # Window 4: Default shell
    tmux new-window -t $session_name -n shell

    # Select first window
    tmux select-window -t $session_name:monitor

    set_color green; echo "[SUCCESS] Session '$session_name' created with 4 windows"; set_color normal
    set_color cyan; echo "[INFO] Windows: monitor, sillytavern, zrok, shell"; set_color normal

    # Attach to session
    if test -z "$TMUX"
        tmux attach -t $session_name
    else
        set_color yellow; echo "[INFO] Already in tmux. Switch with: tmux switch-client -t $session_name"; set_color normal
    end
end
