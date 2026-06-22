#!/usr/bin/env fish

function run_with_hyprshade_workaround --description 'Temporarily disable hyprshade while running a command'
    if type -q hyprshade
        set -l shader (hyprshade current 2>/dev/null; or echo "")
        if test -n "$shader" -a "$shader" != "Off"
            hyprshade off >/dev/null 2>&1
            $argv
            set -l ret $status
            hyprshade on $shader >/dev/null 2>&1; or true
            return $ret
        end
    end
    $argv
end

set -l MODE (set -q argv[1]; and echo $argv[1]; or echo "region")
set -l DIR "$HOME/Pictures/Screenshots"
set -l FILE "$DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"

switch $MODE
    case region area
        run_with_hyprshade_workaround grimblast --notify --freeze copysave area "$FILE"
    case monitor screen output
        run_with_hyprshade_workaround grimblast --notify --freeze copysave output "$FILE"
    case window active
        run_with_hyprshade_workaround grimblast --notify --freeze copysave active "$FILE"
    case '*'
        echo "Usage: screenshot [region|monitor|window]"
        exit 1
end
