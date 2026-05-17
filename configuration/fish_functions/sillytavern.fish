function sillytavern
    set -l action $argv[1]

    switch "$action"
        case restart
            systemctl restart sillytavern
            journalctl -u sillytavern -n 30 -f

        case logs
            journalctl -u sillytavern -n 60 -f

        case status
            systemctl status sillytavern --no-pager

        case stop
            systemctl stop sillytavern

        case start
            systemctl start sillytavern

        case data
            echo "SillyTavern data: /var/lib/SillyTavern/"
            ls -la /var/lib/SillyTavern/

        case ''
            sillytavern status

        case '*'
            echo "Usage: sillytavern [restart|logs|status|stop|start|data]"
            return 1
    end
end
