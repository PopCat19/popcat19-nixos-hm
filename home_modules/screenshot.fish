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
    echo $app | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g; s/[^a-z0-9._-]/-/g; s/-+/-/g; s/^-+|-+$//g'
end

function next_filename
    set app $argv[1]
    set date (date +%Y%m%d)
    set prefix "{$app}_{$date}-"
    set max 0

    for f in $XDG_SCREENSHOTS_DIR/$prefix*.png
        if test -f $f
            set base (basename $f)
            if string match -r "^$app\\_$date\\-([0-9]+)\\.png\$" $base >/dev/null
                set match (string match -r "^$app\\_$date\\-([0-9]+)\\.png\$" $base)
                set n $match[2]
                if test $n -gt $max
                    set max $n
                end
            end
        end
    end

    echo "{$app}_{$date}-"(math $max + 1)".png"
end

function run_with_hyprshade_workaround
    set shader (hyprshade current 2>/dev/null; or echo "")
    if test -n "$shader" -a "$shader" != "Off"
        hyprshade off >/dev/null 2>&1
        $argv
        hyprshade on $shader >/dev/null 2>&1; or true
    else
        $argv
    end
end

function take_screenshot
    set mode $argv[1]
    set screenshot_path "$XDG_SCREENSHOTS_DIR/$FILENAME"

    if run_with_hyprshade_workaround hyprshot --freeze --silent -m $mode -o $XDG_SCREENSHOTS_DIR -f $FILENAME
        if test -f $screenshot_path
            notify-send "Screenshot" "$mode screenshot saved and copied: $FILENAME" -i camera-photo; or true
            echo "Saved and copied: $screenshot_path"
        else
            echo "Screenshot cancelled - no file created"
        end
    else
        test -f $screenshot_path; and rm -f $screenshot_path
        echo "Screenshot cancelled"(test -f $screenshot_path; and echo " - cleaned up partial file"; or echo "")
    end
end

set MODE (set -q argv[1]; and echo $argv[1]; or echo "monitor")
set SCREENSHOT_DIR "$HOME/Pictures/Screenshots"
set XDG_SCREENSHOTS_DIR (set -q XDG_SCREENSHOTS_DIR; and echo $XDG_SCREENSHOTS_DIR; or echo $SCREENSHOT_DIR)

mkdir -p $XDG_SCREENSHOTS_DIR

set APP_NAME (get_app_name)
set FILENAME (next_filename $APP_NAME)

switch $MODE
    case monitor full
        take_screenshot output
    case region area
        take_screenshot region
    case '*'
        echo "Usage: screenshot [monitor|region]"
        echo ""
        echo "Modes:"
        echo "  monitor - Screenshot current monitor (default)"
        echo "  region  - Screenshot selected region"
        exit 1
end