#!/usr/bin/env bash

# Region Screenshot Script
# Takes a screenshot of a selected region and saves it with timestamp

set -euo pipefail

# Configuration
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="screenshot_region_${TIMESTAMP}.png"
FILEPATH="${SCREENSHOT_DIR}/${FILENAME}"

# Ensure screenshot directory exists
mkdir -p "$SCREENSHOT_DIR"

# Take region screenshot using grim + slurp (Wayland screenshot tools)
if command -v grim &> /dev/null && command -v slurp &> /dev/null; then
    # Use slurp to select region, then grim to capture it
    REGION=$(slurp)
    if [[ -n "$REGION" ]]; then
        grim -g "$REGION" "$FILEPATH"

        # Copy to clipboard if wl-copy is available
        if command -v wl-copy &> /dev/null; then
            wl-copy < "$FILEPATH"
            echo "Region screenshot saved to: $FILEPATH"
            echo "Screenshot copied to clipboard"
        else
            echo "Region screenshot saved to: $FILEPATH"
            echo "wl-copy not found - screenshot not copied to clipboard"
        fi

        # Show notification if notify-send is available
        if command -v notify-send &> /dev/null; then
            notify-send "Screenshot" "Region screenshot saved to Pictures/Screenshots" -i "$FILEPATH"
        fi
    else
        echo "Screenshot cancelled - no region selected"
        exit 0
    fi

elif command -v grim &> /dev/null; then
    echo "Error: slurp not found. Please install slurp for region selection."
    exit 1
else
    echo "Error: grim not found. Please install grim for Wayland screenshots."
    exit 1
fi
