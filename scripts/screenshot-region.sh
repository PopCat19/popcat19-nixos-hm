#!/usr/bin/env bash

# Region Screenshot Script for Hyprland
# Interactive region selection with editing capabilities
# Limited to current monitor where mouse cursor is located

set -euo pipefail

# Configuration
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="screenshot_region_${TIMESTAMP}.png"
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

# Function to take region screenshot with monitor constraint
take_region_screenshot() {
    local monitor_geometry
    monitor_geometry=$(get_current_monitor)

    if [[ -z "$monitor_geometry" ]]; then
        echo "Error: Could not determine current monitor" >&2
        return 1
    fi

    echo "Region selection limited to monitor: $monitor_geometry"

    # Use slurp with monitor constraint and grim to capture
    local selection
    if selection=$(slurp -g "$monitor_geometry"); then
        grim -g "$selection" "$FILEPATH"
        return 0
    else
        echo "Region selection cancelled or failed" >&2
        return 1
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
        notify-send "Screenshot" "Region captured on current monitor\nSaved: $FILENAME\nCopied to clipboard" -i "$FILEPATH" -t 3000
    fi

    echo "Screenshot saved: $FILEPATH"
    echo "Copied to clipboard"
else
    echo "Error: Failed to take region screenshot (selection cancelled or failed)" >&2
    exit 1
fi
