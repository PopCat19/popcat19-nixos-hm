{ config, pkgs, ... }:

{
  # Screenshot configuration for Hyprland using grimblast
  # Rewritten with KISS principle for stability and efficiency

  home.packages = with pkgs; [
    # Core screenshot tools
    grimblast                          # Primary screenshot tool for Hyprland
    grim                               # Wayland screenshot utility (dependency)
    slurp                              # Region selection (dependency)
    wl-clipboard                       # Clipboard utilities (dependency)
    libnotify                          # Desktop notifications (dependency)
  ];

  # Create Screenshots directory
  home.file."Pictures/Screenshots/.keep".text = "";

  # Consolidated screenshot script
  home.file.".local/bin/screenshot" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      set -euo pipefail

      # --- Configuration ---
      SCREENSHOT_DIR="$HOME/Pictures/Screenshots"

      # --- Functions ---
      show_usage() {
        echo "Usage: $0 {full|screen|region|area}"
        echo "  full, screen   - Take a fullscreen screenshot"
        echo "  region, area   - Select a region to screenshot"
      }

      # --- Main Script ---
      mkdir -p "$SCREENSHOT_DIR"

      case "''${1:-}" in
        full|screen)
          # Get current shader and disable it to prevent it from affecting the screenshot
          current_shader=$(hyprshade current)
          if [[ "$current_shader" != "None" ]]; then
            hyprshade off
          fi

          # Take screenshot of the active monitor
          grimblast --notify copysave active "$SCREENSHOT_DIR/screenshot_$(date +%Y%m%d_%H%M%S).png"

          # Restore the shader if it was active
          if [[ "$current_shader" != "None" ]]; then
            hyprshade on "$current_shader"
          fi
          ;;
        region|area)
          # Get current shader and disable it to prevent it from affecting the screenshot
          current_shader=$(hyprshade current)
          if [[ "$current_shader" != "None" ]]; then
            hyprshade off
          fi

          grimblast --notify copysave area "$SCREENSHOT_DIR/screenshot_region_$(date +%Y%m%d_%H%M%S).png"

          # Restore the shader if it was active
          if [[ "$current_shader" != "None" ]]; then
            hyprshade on "$current_shader"
          fi
          ;;
        *)
          show_usage
          exit 1
          ;;
      esac
    '';
  };
}
