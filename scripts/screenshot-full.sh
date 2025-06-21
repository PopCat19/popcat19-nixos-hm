#!/usr/bin/env bash

# Full Screen Screenshot Script
# Takes a screenshot of the current monitor and saves it with timestamp

set -euo pipefail

# Configuration
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="screenshot_${TIMESTAMP}.png"
FILEPATH="${SCREENSHOT_DIR}/${FILENAME}"

# Ensure screenshot directory exists
mkdir -p "$SCREENSHOT_DIR"

# Take screenshot using grim (Wayland screenshot tool)
if command -v grim &> /dev/null; then
    grim "$FILEPATH"

    # Copy to clipboard if wl-copy is available
    if command -v wl-copy &> /dev/null; then
        wl-copy < "$FILEPATH"
        echo "Screenshot saved to: $FILEPATH"
        echo "Screenshot copied to clipboard"
    else
        echo "Screenshot saved to: $FILEPATH"
        echo "wl-copy not found - screenshot not copied to clipboard"
    fi

    # Show notification if notify-send is available
    if command -v notify-send &> /dev/null; then
        notify-send "Screenshot" "Full screenshot saved to Pictures/Screenshots" -i "$FILEPATH"
    fi

else
    echo "Error: grim not found. Please install grim for Wayland screenshots."
    exit 1
fi
