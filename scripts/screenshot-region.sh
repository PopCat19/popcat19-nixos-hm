#!/usr/bin/env bash

# Region Screenshot Script for Hyprland
# Interactive region selection with editing capabilities

set -euo pipefail

# Configuration
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="screenshot_region_${TIMESTAMP}.png"
FILEPATH="${SCREENSHOT_DIR}/${FILENAME}"

# Create screenshots directory if it doesn't exist
mkdir -p "$SCREENSHOT_DIR"

# Check if hyprshade argument is provided
HYPRSHADE_MODE=false
if [[ "${1:-}" == "--hyprshade" ]] || [[ "${1:-}" == "-s" ]]; then
    HYPRSHADE_MODE=true
fi

# Function to take region screenshot
take_region_screenshot() {
    local temp_file="${FILEPATH}.tmp"

    if $HYPRSHADE_MODE; then
        # Temporarily disable hyprshade for clean screenshot
        if command -v hyprshade >/dev/null 2>&1; then
            hyprshade off
            sleep 0.2  # Brief pause to ensure shader is disabled

            # Take region screenshot
            if grim -g "$(slurp)" "$temp_file"; then
                mv "$temp_file" "$FILEPATH"
                sleep 0.1
                hyprshade auto  # Re-enable auto mode
                return 0
            else
                hyprshade auto  # Re-enable auto mode even if screenshot failed
                return 1
            fi
        else
            echo "Warning: hyprshade not found, taking regular screenshot"
            grim -g "$(slurp)" "$FILEPATH"
        fi
    else
        # Regular region screenshot with current display state
        grim -g "$(slurp)" "$FILEPATH"
    fi
}

# Function to open screenshot in editor
open_in_editor() {
    local filepath="$1"

    # Try different editors in order of preference
    if command -v satty >/dev/null 2>&1; then
        satty --filename "$filepath" --output-filename "$filepath"
    elif command -v swappy >/dev/null 2>&1; then
        swappy -f "$filepath"
    else
        echo "No screenshot editor found (satty or swappy)"
        return 1
    fi
}

# Take the screenshot
if take_region_screenshot; then
    # Ask if user wants to edit the screenshot
    if command -v zenity >/dev/null 2>&1; then
        if zenity --question --title="Screenshot Captured" --text="Do you want to edit the screenshot?" --width=300 2>/dev/null; then
            open_in_editor "$FILEPATH"
        fi
    elif command -v kdialog >/dev/null 2>&1; then
        if kdialog --yesno "Do you want to edit the screenshot?" --title "Screenshot Captured" 2>/dev/null; then
            open_in_editor "$FILEPATH"
        fi
    else
        # Fallback: always try to open editor
        open_in_editor "$FILEPATH" || true
    fi

    # Copy to clipboard
    wl-copy < "$FILEPATH"

    # Show notification
    if command -v notify-send >/dev/null 2>&1; then
        if $HYPRSHADE_MODE; then
            notify-send "Screenshot" "Region captured (hyprshade disabled)\nSaved: $FILENAME\nCopied to clipboard" -i "$FILEPATH" -t 3000
        else
            notify-send "Screenshot" "Region captured\nSaved: $FILENAME\nCopied to clipboard" -i "$FILEPATH" -t 3000
        fi
    fi

    echo "Screenshot saved: $FILEPATH"
    echo "Copied to clipboard"
else
    echo "Error: Failed to take region screenshot (selection cancelled or failed)" >&2
    exit 1
fi
