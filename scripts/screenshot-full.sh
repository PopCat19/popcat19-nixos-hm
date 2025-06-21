#!/usr/bin/env bash

# Fullscreen Screenshot Script for Hyprland
# Captures screenshot of the monitor where the mouse cursor is currently located

set -euo pipefail

# Configuration
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="screenshot_${TIMESTAMP}.png"
FILEPATH="${SCREENSHOT_DIR}/${FILENAME}"

# Create screenshots directory if it doesn't exist
mkdir -p "$SCREENSHOT_DIR"

# Function to get current monitor info based on mouse cursor position
get_current_monitor() {
    # Get mouse cursor position
    local cursor_pos
    cursor_pos=$(hyprctl cursorpos | tr -d ' ')

    # Parse cursor coordinates
    local cursor_x cursor_y
    cursor_x=$(echo "$cursor_pos" | cut -d',' -f1)
    cursor_y=$(echo "$cursor_pos" | cut -d',' -f2)

    # Get monitor information and find which monitor contains the cursor
    hyprctl monitors -j | jq -r --argjson cx "$cursor_x" --argjson cy "$cursor_y" '
        .[] |
        select(
            $cx >= .x and $cx < (.x + .width) and
            $cy >= .y and $cy < (.y + .height)
        ) |
        "\(.x),\(.y) \(.width)x\(.height)"
    '
}

# Function to take screenshot of current monitor
take_screenshot() {
    local monitor_geometry
    monitor_geometry=$(get_current_monitor)

    if [[ -z "$monitor_geometry" ]]; then
        echo "Error: Could not determine current monitor" >&2
        return 1
    fi

    echo "Capturing monitor: $monitor_geometry"
    grim -g "$monitor_geometry" "$FILEPATH"
}

# Take the screenshot
if take_screenshot; then
    # Copy to clipboard
    wl-copy < "$FILEPATH"

    # Show notification
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Screenshot" "Current monitor captured\nSaved: $FILENAME\nCopied to clipboard" -i "$FILEPATH" -t 3000
    fi

    echo "Screenshot saved: $FILEPATH"
    echo "Copied to clipboard"
else
    echo "Error: Failed to take screenshot" >&2
    exit 1
fi
