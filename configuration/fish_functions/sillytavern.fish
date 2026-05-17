# sillytavern.fish
#
# Purpose: Manage SillyTavern Docker container via systemd
#
# This function:
# - Pulls latest image and restarts the container
# - Shows container status and logs
# - Called by dev-session for container lifecycle

function sillytavern
    set -l action $argv[1]

    switch "$action"
        case restart update
            echo "Pulling latest SillyTavern image..."
            docker pull ghcr.io/sillytavern/sillytavern:latest
            echo "Restarting SillyTavern container..."
            systemctl restart docker-container-sillytavern
            journalctl -u docker-container-sillytavern -n 20 -f

        case logs
            journalctl -u docker-container-sillytavern -n 50 -f

        case status
            systemctl status docker-container-sillytavern --no-pager
            echo
            docker ps --filter name=sillytavern --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

        case stop
            systemctl stop docker-container-sillytavern

        case start
            systemctl start docker-container-sillytavern

        case ''
            sillytavern status

        case '*'
            echo "Usage: sillytavern [restart|logs|status|stop|start]"
            return 1
    end
end
