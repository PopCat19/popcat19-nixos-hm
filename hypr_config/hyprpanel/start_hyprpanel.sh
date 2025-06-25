#!/usr/bin/env bash

# HyprPanel Startup Script
# =========================
# This script starts HyprPanel with the custom configuration
# Created as a workaround for the broken Home Manager module

# Configuration file path
CONFIG_DIR="$HOME/.config/hypr/hyprpanel"
CONFIG_FILE="$CONFIG_DIR/config.json"

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

# Copy our config if it doesn't exist or if our version is newer
NIXOS_CONFIG="/home/popcat19/nixos-config/hypr_config/hyprpanel/config.json"
if [[ -f "$NIXOS_CONFIG" ]]; then
    if [[ ! -f "$CONFIG_FILE" ]] || [[ "$NIXOS_CONFIG" -nt "$CONFIG_FILE" ]]; then
        echo "Copying HyprPanel configuration..."
        cp "$NIXOS_CONFIG" "$CONFIG_FILE"
    fi
fi

# Kill any existing HyprPanel instances
pkill -f hyprpanel 2>/dev/null || true

# Wait a moment for processes to clean up
sleep 1

# Start HyprPanel
echo "Starting HyprPanel..."
exec hyprpanel
