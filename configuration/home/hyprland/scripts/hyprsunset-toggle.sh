#!/usr/bin/env bash
# hyprsunset-toggle.sh
#
# Purpose: Toggle hyprsunset blue-light filter between 3200K and identity

STATE="$XDG_RUNTIME_DIR/hyprsunset-active"

if [ -f "$STATE" ]; then
    hyprctl hyprsunset identity 2>/dev/null
    rm -f "$STATE"
else
    hyprctl hyprsunset temperature 3200 2>/dev/null
    touch "$STATE"
fi
