#!/usr/bin/env bash

# Fullscreen Screenshot Script for Hyprland
# Supports both regular and hyprshade modes

set -euo pipefail

# Configuration
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="screenshot_${TIMESTAMP}.png"
FILEPATH="${SCREENSHOT_DIR}/${FILENAME}"

# Create screenshots directory if it doesn't exist
mkdir -p "$SCREENSHOT_DIR"

# Check if hyprshade argument is provided
HYPRSHADE_MODE=false
if [[ "${1:-}" == "--hyprshade" ]] || [[ "${1:-}" == "-s" ]]; then
    HYPRSHADE_MODE=true
fi

# Function to take screenshot
take_screenshot() {
    if $HYPRSHADE_MODE; then
        # Temporarily disable hyprshade for clean screenshot
        if command -v hyprshade >/dev/null 2>&1; then
            hyprshade off
            sleep 0.2  # Brief pause to ensure shader is disabled
            grim "$FILEPATH"
            sleep 0.1
            hyprshade auto  # Re-enable auto mode
        else
            echo "Warning: hyprshade not found, taking regular screenshot"
            grim "$FILEPATH"
        fi
    else
        # Regular screenshot with current display state
        grim "$FILEPATH"
    fi
}

# Take the screenshot
if take_screenshot; then
    # Copy to clipboard
    wl-copy < "$FILEPATH"

    # Show notification
    if command -v notify-send >/dev/null 2>&1; then
        if $HYPRSHADE_MODE; then
            notify-send "Screenshot" "Fullscreen captured (hyprshade disabled)\nSaved: $FILENAME\nCopied to clipboard" -i "$FILEPATH" -t 3000
        else
            notify-send "Screenshot" "Fullscreen captured\nSaved: $FILENAME\nCopied to clipboard" -i "$FILEPATH" -t 3000
        fi
    fi

    echo "Screenshot saved: $FILEPATH"
    echo "Copied to clipboard"
else
    echo "Error: Failed to take screenshot" >&2
    exit 1
fi
