#!/usr/bin/env fish

# Screenshot wrapper using hyprshot with hyprshade integration
# Usage: screenshot [monitor|region|window|both] [--keep-shader]
#
# Behavior:
# - Uses hyprshot with --freeze for clean capture
# - Always saves to XDG_SCREENSHOTS_DIR (defaults to ~/Pictures/Screenshots)
# - Copies PNG to clipboard when wl-copy/xclip are available
# - Filename: appname_yyyymmdd-N.png (N increments per day/app)
# - Temporarily disables hyprshade during capture by default (restores after)
# - Use --keep-shader flag to preserve hyprshade effects in screenshot
# - 'both' mode: takes both monitor and region screenshots

function _slugify_app_name --description 'Normalize string to filesystem-safe slug'
    set -l s $argv
    if test -z "$s"
        echo "screen"
        return
    end
    set -l out (string lower -- $s)
    set out (string replace -ra '[^a-z0-9._-]' '-' -- $out)
    set out (string replace -ra -- '-+' '-' $out)
    set out (string trim -c '-' -- $out)
    if test -z "$out"
        echo "screen"
    else
        echo $out
    end
end

function get_app_name --description 'Detect active window class via hyprctl'
    set -l app "screen"
    if type -q hyprctl
        set -l json (hyprctl activewindow -j 2>/dev/null)
        if test -n "$json"
            set -l cls (echo $json | jq -r '.class // empty' 2>/dev/null)
            if test -n "$cls"
                set app $cls
            end
        end
    end
    _slugify_app_name $app
end

function next_filename --description 'Generate next incremental filename'
    # args: <dir> <app>
    set -l dir $argv[1]
    set -l app $argv[2]
    set -l date (date +%Y%m%d)
    set -l prefix (printf "%s_%s-" $app $date)
    set -l n 1
    while test -e "$dir/$prefix$n.png"
        set n (math $n + 1)
    end
    echo "$prefix$n.png"
end

function run_with_hyprshade_workaround --description 'Temporarily disable hyprshade while running a command'
    # args: [--keep-shader] <command...>
    set -l keep_shader false
    if test "$argv[1]" = "--keep-shader"
        set keep_shader true
        set -e argv[1]
    end

    if test "$keep_shader" = "true"
        # Keep shader active, just run the command
        $argv
        return
    end

    if type -q hyprshade
        set -l shader (hyprshade current 2>/dev/null; or echo "")
        if test -n "$shader" -a "$shader" != "Off"
            hyprshade off >/dev/null 2>&1
            $argv
            hyprshade on $shader >/dev/null 2>&1; or true
            return
        end
    end
    $argv
end

function copy_to_clipboard --description 'Copy PNG to clipboard if tools available'
    set -l path $argv[1]
    if test -z "$path"; or not test -f "$path"
        return 1
    end
    if type -q wl-copy
        wl-copy --type image/png < "$path"
        return
    else if type -q xclip
        xclip -selection clipboard -t image/png -i "$path"
        return
    end
    # No clipboard utility available; skip silently
end

function take_screenshot --description 'Perform capture using hyprshot'
    # args: <hyprshot-mode> <dir> <filename> [--keep-shader]
    set -l mode $argv[1]
    set -l dir $argv[2]
    set -l filename $argv[3]
    set -l keep_shader false
    if test "$argv[4]" = "--keep-shader"
        set keep_shader true
    end
    set -l screenshot_path "$dir/$filename"

    if not type -q hyprshot
        echo "hyprshot not found in PATH"
        return 127
    end

    set -l hyprshot_cmd hyprshot --freeze --silent -m $mode -o "$dir" -f "$filename"
    
    if test "$keep_shader" = "true"
        if run_with_hyprshade_workaround --keep-shader $hyprshot_cmd
            if test -f "$screenshot_path"
                copy_to_clipboard "$screenshot_path"; or true
                notify-send "Screenshot" "$mode screenshot saved (with shader): $filename" -i camera-photo; or true
                echo "Saved: $screenshot_path (with shader)"
            else
                echo "Screenshot cancelled - no file created"
            end
        else
            if test -f "$screenshot_path"
                rm -f "$screenshot_path"
                echo "Screenshot cancelled - cleaned up partial file"
            else
                echo "Screenshot cancelled"
            end
            return 1
        end
    else
        if run_with_hyprshade_workaround $hyprshot_cmd
            if test -f "$screenshot_path"
                copy_to_clipboard "$screenshot_path"; or true
                notify-send "Screenshot" "$mode screenshot saved: $filename" -i camera-photo; or true
                echo "Saved: $screenshot_path"
            else
                echo "Screenshot cancelled - no file created"
            end
        else
            if test -f "$screenshot_path"
                rm -f "$screenshot_path"
                echo "Screenshot cancelled - cleaned up partial file"
            else
                echo "Screenshot cancelled"
            end
            return 1
        end
    end
end

function take_both_screenshots --description 'Take both monitor and region screenshots'
    # args: <dir> <base_filename> [--keep-shader]
    set -l dir $argv[1]
    set -l base_filename $argv[2]
    set -l keep_shader_flag ""
    if test "$argv[3]" = "--keep-shader"
        set keep_shader_flag "--keep-shader"
    end

    # Take monitor screenshot
    set -l monitor_filename (string replace ".png" "_monitor.png" "$base_filename")
    take_screenshot output "$dir" "$monitor_filename" $keep_shader_flag

    # Take region screenshot
    set -l region_filename (string replace ".png" "_region.png" "$base_filename")
    take_screenshot region "$dir" "$region_filename" $keep_shader_flag
end

# Parse arguments
set -l MODE "monitor"
set -l KEEP_SHADER false

for arg in $argv
    switch $arg
        case '--keep-shader'
            set KEEP_SHADER true
        case '-*'
            echo "Unknown option: $arg"
            exit 1
        case '*'
            set MODE $arg
    end
end

# Parameters and defaults
set -l DEFAULT_DIR "$HOME/Pictures/Screenshots"
set -l XDG_SCREENSHOTS_DIR (set -q XDG_SCREENSHOTS_DIR; and echo $XDG_SCREENSHOTS_DIR; or echo $DEFAULT_DIR)

mkdir -p "$XDG_SCREENSHOTS_DIR"

set -l APP_NAME (get_app_name)
set -l FILENAME (next_filename "$XDG_SCREENSHOTS_DIR" "$APP_NAME")
set -l SHADER_FLAG ""
if test "$KEEP_SHADER" = "true"
    set SHADER_FLAG "--keep-shader"
end

switch $MODE
    case monitor full
        take_screenshot output "$XDG_SCREENSHOTS_DIR" "$FILENAME" $SHADER_FLAG
    case region area
        take_screenshot region "$XDG_SCREENSHOTS_DIR" "$FILENAME" $SHADER_FLAG
    case window active
        take_screenshot window "$XDG_SCREENSHOTS_DIR" "$FILENAME" $SHADER_FLAG
    case both
        take_both_screenshots "$XDG_SCREENSHOTS_DIR" "$FILENAME" $SHADER_FLAG
    case '*'
        echo "Usage: screenshot [monitor|region|window|both] [--keep-shader]"
        echo ""
        echo "Modes:"
        echo "  monitor - Screenshot current monitor (default)"
        echo "  region  - Screenshot selected region"
        echo "  window  - Screenshot active window"
        echo "  both    - Screenshot both monitor and region"
        echo ""
        echo "Options:"
        echo "  --keep-shader - Preserve hyprshade effects in screenshot"
        exit 1
end
