{ config, pkgs, ... }:

{
  # Screenshot configuration for Hyprland using grimblast

  home.packages = with pkgs; [
    # Core screenshot tools
    grimblast                          # Primary screenshot tool for Hyprland
    grimblast                          # Keep as fallback
    hyprshot                           # Preferred tool for Hyprland with freeze support
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
      
      # Screenshot wrapper using hyprshot with hyprshade integration
      # Usage: screenshot [monitor|region] [save]
      #
      # Features:
      # - Uses hyprshot with --freeze for clean capture
      # - Copies to clipboard by default (no file saved)
      # - If second arg is "save", also saves to ~/Pictures/Screenshots
      # - Temporarily disables hyprshade around the capture, then restores it
       
      set -euo pipefail
       
      MODE="''${1:-monitor}"
      EXTRA_ACTION="''${2:-}"   # "save" to save+copy; default is copy-only
      SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
      : "${XDG_SCREENSHOTS_DIR:=$SCREENSHOT_DIR}"
       
      # Ensure screenshot directory exists
      mkdir -p "$SCREENSHOT_DIR"
      
      # Run capture command while toggling hyprshade off during capture
      run_with_hyprshade_workaround() {
        local cmd_pid shader
        # Kick off capture in background to allow us to toggle shader off mid-capture
        ( "$@" ) & cmd_pid=$!
        shader="$(hyprshade current 2>/dev/null || true)"
        if [[ -n "$shader" && "$shader" != "Off" ]]; then
          # Give hyprshot a moment to initialize framebuffer, then disable shader
          sleep 0.01 && hyprshade off >/dev/null 2>&1 &
          wait $cmd_pid
          hyprshade on "$shader" >/dev/null 2>&1 || true
        else
          wait $cmd_pid
        fi
      }
       
      case "$MODE" in
        "monitor"|"full")
          if [[ "$EXTRA_ACTION" == "save" ]]; then
            # Save and copy (hyprshot saves and copies unless clipboard-only is set)
            FILENAME="screenshot_$(date +%Y%m%d_%H%M%S).png"
            run_with_hyprshade_workaround hyprshot --freeze --silent -m output -o "$XDG_SCREENSHOTS_DIR" -f "$FILENAME"
            notify-send "Screenshot" "Monitor screenshot saved and copied: $FILENAME" -i camera-photo || true
            echo "Saved and copied: $XDG_SCREENSHOTS_DIR/$FILENAME"
          else
            # Copy to clipboard only (default)
            run_with_hyprshade_workaround hyprshot --freeze --silent -m output --clipboard-only
            notify-send "Screenshot" "Monitor screenshot copied to clipboard" -i camera-photo || true
            echo "Monitor screenshot copied to clipboard"
          fi
          ;;
        "region"|"area")
          if [[ "$EXTRA_ACTION" == "save" ]]; then
            # Save and copy selected region
            FILENAME="screenshot_region_$(date +%Y%m%d_%H%M%S).png"
            run_with_hyprshade_workaround hyprshot --freeze --silent -m region -o "$XDG_SCREENSHOTS_DIR" -f "$FILENAME"
            notify-send "Screenshot" "Region screenshot saved and copied: $FILENAME" -i camera-photo || true
            echo "Saved and copied: $XDG_SCREENSHOTS_DIR/$FILENAME"
          else
            # Copy to clipboard only selected region
            run_with_hyprshade_workaround hyprshot --freeze --silent -m region --clipboard-only
            notify-send "Screenshot" "Region screenshot copied to clipboard" -i camera-photo || true
            echo "Region screenshot copied to clipboard"
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
          echo "  save    - Also save to ~/Pictures/Screenshots (copy remains default)"
          echo ""
          echo "Examples:"
          echo "  screenshot                    # Monitor screenshot copied to clipboard"
          echo "  screenshot region             # Region screenshot copied to clipboard"
          echo "  screenshot monitor save       # Monitor: save to file (and copy)"
          echo "  screenshot region save        # Region: save to file (and copy)"
          exit 1
          ;;
      esac
    '';
  };
}
