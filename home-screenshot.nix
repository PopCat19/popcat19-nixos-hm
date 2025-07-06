{ config, pkgs, ... }:

{
  # Screenshot configuration for Hyprland using grimblast

  home.packages = with pkgs; [
    # Core screenshot tools
    grimblast                          # Primary screenshot tool for Hyprland
    kdePackages.gwenview               # Image viewer
    libnotify                          # Desktop notifications (notify-send)
  ];

  # Create Screenshots directory
  home.file."Pictures/Screenshots/.keep".text = "";

  # Screenshot wrapper script for grimblast with hyprshade integration
  home.file.".local/bin/screenshot" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      
      # Screenshot wrapper using grimblast with hyprshade integration
      # Usage: screenshot [monitor|region] [save]
      #
      # Features:
      # - Temporarily disables hyprshade for accurate color capture
      # - Uses grimblast native monitor detection and region selection
      # - Copies to clipboard by default, optionally saves to file
      # - Restores hyprshade state after screenshot
      
      set -euo pipefail
      
      MODE="''${1:-monitor}"
      SAVE_FILE="''${2:-}"
      SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
      
      # Ensure screenshot directory exists
      mkdir -p "$SCREENSHOT_DIR"
      
      # Function to restore hyprshade on exit (cleanup)
      cleanup() {
        if [[ -n "''${SAVED_SHADER:-}" && "$SAVED_SHADER" != "Off" ]]; then
          hyprshade on "$SAVED_SHADER" 2>/dev/null || true
        fi
      }
      
      # Set trap to restore shader on script exit
      trap cleanup EXIT INT TERM
      
      # Save current shader state
      SAVED_SHADER=$(hyprshade current 2>/dev/null || echo "Off")
      
      # Disable hyprshade for clean capture
      if [[ "$SAVED_SHADER" != "Off" ]]; then
        hyprshade off 2>/dev/null || true
        sleep 0.1  # Brief delay to ensure shader is off
      fi
      
      case "$MODE" in
        "monitor"|"full")
          if [[ "$SAVE_FILE" == "save" ]]; then
            # Save to file with timestamp
            FILENAME="screenshot_$(date +%Y%m%d_%H%M%S).png"
            FILEPATH="$SCREENSHOT_DIR/$FILENAME"
            if grimblast save output "$FILEPATH"; then
              notify-send "Screenshot" "Monitor screenshot saved to $FILENAME" -i camera-photo || true
              echo "Screenshot saved: $FILEPATH"
            else
              notify-send "Screenshot Error" "Failed to save monitor screenshot" -i dialog-error || true
              exit 1
            fi
          else
            # Copy to clipboard (default)
            if grimblast copy output; then
              notify-send "Screenshot" "Monitor screenshot copied to clipboard" -i camera-photo || true
              echo "Monitor screenshot copied to clipboard"
            else
              notify-send "Screenshot Error" "Failed to capture monitor screenshot" -i dialog-error || true
              exit 1
            fi
          fi
          ;;
        "region"|"area")
          if [[ "$SAVE_FILE" == "save" ]]; then
            # Save to file with timestamp
            FILENAME="screenshot_region_$(date +%Y%m%d_%H%M%S).png"
            FILEPATH="$SCREENSHOT_DIR/$FILENAME"
            if grimblast save area "$FILEPATH"; then
              notify-send "Screenshot" "Region screenshot saved to $FILENAME" -i camera-photo || true
              echo "Screenshot saved: $FILEPATH"
            else
              notify-send "Screenshot Error" "Failed to save region screenshot" -i dialog-error || true
              exit 1
            fi
          else
            # Copy to clipboard (default)
            if grimblast copy area; then
              notify-send "Screenshot" "Region screenshot copied to clipboard" -i camera-photo || true
              echo "Region screenshot copied to clipboard"
            else
              notify-send "Screenshot Error" "Failed to capture region screenshot" -i dialog-error || true
              exit 1
            fi
          fi
          ;;
        *)
          echo "Usage: screenshot [monitor|region] [save]"
          echo ""
          echo "Modes:"
          echo "  monitor - Screenshot current monitor (default)"
          echo "  region  - Screenshot selected region"
          echo ""
          echo "Options:"
          echo "  save    - Save to ~/Pictures/Screenshots/ instead of clipboard"
          echo ""
          echo "Examples:"
          echo "  screenshot                    # Monitor screenshot to clipboard"
          echo "  screenshot region             # Region screenshot to clipboard"
          echo "  screenshot monitor save       # Monitor screenshot to file"
          echo "  screenshot region save        # Region screenshot to file"
          exit 1
          ;;
      esac
    '';
  };
}
