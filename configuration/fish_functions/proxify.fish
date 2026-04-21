# proxify.fish
#
# Purpose: Run commands detached from PTY with proxy settings
#
# This function:
# - Accepts command via arguments or stdin
# - Injects proxy flags for Chromium/Electron apps
# - Detaches process via uwsm or standard backgrounding
# - Decouples application lifecycle from shell
#
# Rationale: Decouples application lifecycle from the shell using systemd scopes.

function proxify
    set -l cmd_args

    if test -z "$argv"
        if test -t 0
            echo "Usage: proxify <command> [args...]"
            return 1
        end
        set cmd_args (cat | string split " ")
    else
        set cmd_args $argv
    end

    if not set -q all_proxy
        set_color yellow; echo "[WARN] No proxy env. Run: proxy_on"; set_color normal
    else
        set -l proxy_addr (string replace -r '^[^:]+://' '' "$all_proxy")
        set_color cyan; echo "[RUN] $cmd_args[1] -> $proxy_addr"; set_color normal
        set cmd_args $cmd_args --proxy-server="socks5://$proxy_addr"
    end

    if command -q uwsm
        uwsm app -- $cmd_args >/dev/null 2>&1 &
        disown
    else
        $cmd_args >/dev/null 2>&1 &
        disown
    end
end
