# Hyprland Powersave Toggle Module
# ================================
# This module provides a script to toggle power-saving settings in Hyprland
# and sets up the necessary keybind (mod+alt+P) to activate it.

{ config, pkgs, ... }:

{
  # Add libnotify for notifications
  home.packages = with pkgs; [
    libnotify                          # Desktop notifications (notify-send)
  ];

  # Create the powersave toggle script
  home.file.".local/bin/powersave-toggle" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Hyprland Powersave Toggle Script
      # Toggles blur, shadow, and VFR settings for power saving

      # Check current blur state to determine if we're in powersave mode
      BLUR_ENABLED=$(hyprctl getoption decoration:blur:enabled | awk 'NR==1{print $2}')

      if [ "$BLUR_ENABLED" = "1" ]; then
          # Currently in normal mode, switch to powersave
          echo "Enabling powersave mode..."
          hyprctl --batch "\
              keyword decoration:blur:enabled false;\
              keyword decoration:shadow:enabled false;\
              keyword misc:vfr true"
          
          # Send notification if available
          if command -v notify-send &> /dev/null; then
              notify-send "Hyprland" "Powersave mode enabled" -i battery-low
          fi
      else
          # Currently in powersave mode, switch to normal
          echo "Disabling powersave mode..."
          hyprctl --batch "\
              keyword decoration:blur:enabled true;\
              keyword decoration:shadow:enabled true;\
              keyword misc:vfr true"
          
          # Send notification if available
          if command -v notify-send &> /dev/null; then
              notify-send "Hyprland" "Powersave mode disabled" -i battery-full
          fi
      fi
    '';
  };
}