#!/usr/bin/env fish

# Screenshot wrapper using hyprshot with hyprshade integration
# Usage: screenshot [monitor|region]
#
# Behavior:
# - Uses hyprshot with --freeze for clean capture
# - Always saves to ~/Pictures/Screenshots AND copies to clipboard
# - Filename: appname_yyyymmdd-count.png (count increments per day/app)
# - Temporarily disables hyprshade around the capture, then restores it

function get_app_name
    set app "screen"
    if command -v hyprctl >/dev/null 2>&1
        set cls (hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty' 2>/dev/null; or echo "")
        if test -n "$cls"
            set app $cls
        end
    end
    set app (echo $app | tr '[:upper:]' '[:lower:]')
    # keep only [a-z0-9-_], convert spaces to dashes
    set app (echo $app | sed 's/ /-/g')
    set app (echo $app | sed -E 's/[^a-z0-9._-]+/-/g' | sed -E 's/-+/-/g' | sed -E 's/^-+|-+$//g')
    echo (test -n "$app"; and echo $app; or echo "screen")
end

function next_filename
    set app $argv[1]
    set date (date +%Y%m%d)
    set prefix "{$app}_{$date}-"
    set max 0

    for f in $XDG_SCREENSHOTS_DIR/$prefix*.png
        if test -f $f
            set base (basename $f)
            if string match -r "^$app\_$date\-([0-9]+)\.png$" $base >/dev/null
                set match (string match -r "^$app\_$date\-([0-9]+)\.png$" $base)
                set n $match[2]
                if test $n -gt $max
                    set max $n
                end
            end
        end
    end

    set next (math $max + 1)
    echo "{$app}_{$date}-{$next}.png"
end

function run_with_hyprshade_workaround
    set shader (hyprshade current 2>/dev/null; or echo "")
    if test -n "$shader" -a "$shader" != "Off"
        # Turn off hyprshade before hyprshot starts
        hyprshade off >/dev/null 2>&1
        # Run the screenshot command
        $argv
        # Restore the shader after hyprshot completes
        hyprshade on $shader >/dev/null 2>&1; or true
    else
        # No shader active, just run the command
        $argv
    end
end

set MODE (set -q argv[1]; and echo $argv[1]; or echo "monitor")
set SCREENSHOT_DIR "$HOME/Pictures/Screenshots"
set XDG_SCREENSHOTS_DIR (set -q XDG_SCREENSHOTS_DIR; and echo $XDG_SCREENSHOTS_DIR; or echo $SCREENSHOT_DIR)

# Ensure screenshot directory exists
mkdir -p $XDG_SCREENSHOTS_DIR

set APP_NAME (get_app_name)
set FILENAME (next_filename $APP_NAME)

switch $MODE
    case monitor full
        # Save and copy: default hyprshot behavior (no --clipboard-only)
        if run_with_hyprshade_workaround hyprshot --freeze --silent -m output -o $XDG_SCREENSHOTS_DIR -f $FILENAME
            notify-send "Screenshot" "Monitor screenshot saved and copied: $FILENAME" -i camera-photo; or true
            echo "Saved and copied: $XDG_SCREENSHOTS_DIR/$FILENAME"
        else
            echo "Screenshot cancelled"
        end
    case region area
        if run_with_hyprshade_workaround hyprshot --freeze --silent -m region -o $XDG_SCREENSHOTS_DIR -f $FILENAME
            notify-send "Screenshot" "Region screenshot saved and copied: $FILENAME" -i camera-photo; or true
            echo "Saved and copied: $XDG_SCREENSHOTS_DIR/$FILENAME"
        else
            echo "Screenshot cancelled"
        end
    case '*'
        echo "Usage: screenshot [monitor|region]"
        echo ""
        echo "Modes:"
        echo "  monitor - Screenshot current monitor (default)"
        echo "  region  - Screenshot selected region"
        exit 1
end