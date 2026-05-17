# dev-session.fish
#
# Purpose: Launch tmux development session with predefined layout
#
# This function:
# - Creates a tmux session with 4 windows
# - Sets up split panes with btop and journalctl
# - Shows SillyTavern container status and zrok tunnel status
# - Attaches to session or creates new one

function dev-session
    set -l session_name "dev"

    if tmux has-session -t $session_name 2>/dev/null
        set_color yellow; echo "[INFO] Session '$session_name' already exists"; set_color normal
        set_color cyan; echo "[INFO] Attaching to existing session..."; set_color normal
        tmux attach -t $session_name
        return 0
    end

    set_color blue; echo "[STEP] Creating tmux session: $session_name"; set_color normal

    # Window 1: System monitoring (btop + journalctl)
    tmux new-session -d -s $session_name -n monitor

    tmux split-window -v -p 20 -t $session_name:monitor
    tmux send-keys -t $session_name:monitor.0 'btop' Enter
    tmux send-keys -t $session_name:monitor.1 'journalctl -f' Enter

    # Window 2: SillyTavern (container logs)
    tmux new-window -t $session_name -n sillytavern
    tmux send-keys -t $session_name:sillytavern 'sillytavern logs' Enter

    # Window 3: Zrok tunnel (systemd service logs)
    tmux new-window -t $session_name -n zrok
    tmux send-keys -t $session_name:zrok 'journalctl -u zrok-share-sillytavern -n 30 -f' Enter

    # Window 4: Default shell
    tmux new-window -t $session_name -n shell

    tmux select-window -t $session_name:monitor

    set_color green; echo "[SUCCESS] Session '$session_name' created with 4 windows"; set_color normal
    set_color cyan; echo "[INFO] Windows: monitor, sillytavern, zrok, shell"; set_color normal

    if test -z "$TMUX"
        tmux attach -t $session_name
    else
        set_color yellow; echo "[INFO] Already in tmux. Switch with: tmux switch-client -t $session_name"; set_color normal
    end
end
