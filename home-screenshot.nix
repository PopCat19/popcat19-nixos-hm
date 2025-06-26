{ config, pkgs, ... }:

{
  # Screenshot configuration for Hyprland using grimblast
  # Rewritten with KISS principle for stability and efficiency

  home.packages = with pkgs; [
    # Core screenshot tools
    grimblast                          # Primary screenshot tool for Hyprland
    kdePackages.gwenview               # Image viewer
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
      IMAGE_VIEWER="''${IMAGE_VIEWER:-${pkgs.kdePackages.gwenview}/bin/gwenview}" # Set default image viewer

      # --- Functions ---
      show_usage() {
        echo "Usage: $0 {full|screen|region|area|copy-path}"
        echo "  full, screen   - Take a fullscreen screenshot"
        echo "  region, area   - Select a region to screenshot"
        echo "  copy-path      - Copy path of the most recent screenshot to clipboard"
      }

      copy_path() {
        local latest_screenshot=$(find "$SCREENSHOT_DIR" -name "screenshot*.png" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)

        if [[ -n "$latest_screenshot" && -f "$latest_screenshot" ]]; then
          echo -n "$latest_screenshot" | ${pkgs.wl-clipboard}/bin/wl-copy
          local filename=$(basename "$latest_screenshot")
          ${pkgs.libnotify}/bin/notify-send "Path Copied" "Screenshot path copied to clipboard: $filename" --icon=edit-copy --expire-time=3000
        else
          ${pkgs.libnotify}/bin/notify-send "No Screenshot Found" "No recent screenshots found in $SCREENSHOT_DIR" --icon=dialog-warning --expire-time=3000
        fi
      }

      send_notification() {
        local image_path="$1"
        local filename=$(basename "$image_path")

        # Send notification with action buttons using D-Bus protocol
        (
          notify-send "Screenshot Saved" \
            "Saved as $filename" \
            --icon=camera-photo \
            --urgency=normal \
            --expire-time=0 \
            --action="open=Open Image" \
            --action="copy=Copy Path" \
            --action="dismiss=Dismiss" | while read action; do
              case "$action" in
                "open")
                  setsid "$IMAGE_VIEWER" "$image_path" &> /dev/null &
                  ;;
                "copy")
                  echo -n "$image_path" | ${pkgs.wl-clipboard}/bin/wl-copy
                  ${pkgs.libnotify}/bin/notify-send "Path Copied" "Screenshot path copied to clipboard" --icon=edit-copy --expire-time=2000
                  ;;
                "dismiss"|"")
                  # Do nothing for dismiss or timeout
                  ;;
              esac
            done
        ) &
      }

      # --- Main Script ---
      mkdir -p "$SCREENSHOT_DIR"

      # Export IMAGE_VIEWER for subprocesses
      export IMAGE_VIEWER



      case "''${1:-}" in
        full|screen)
          # Get current shader and disable it to prevent it from affecting the screenshot
          current_shader=$(hyprshade current)
          if [[ "$current_shader" != "None" ]]; then
            hyprshade off
          fi

          # Take screenshot of the current active output
          filepath="$SCREENSHOT_DIR/screenshot_$(date +%Y%m%d_%H%M%S).png"
          grimblast copysave output "$filepath"

          # Restore the shader if it was active
          if [[ "$current_shader" != "None" ]]; then
            hyprshade on "$current_shader"
          fi

          send_notification "$filepath"
          ;;
        region|area)
          # Get current shader and disable it to prevent it from affecting the screenshot
          current_shader=$(hyprshade current)
          if [[ "$current_shader" != "None" ]]; then
            hyprshade off
          fi

          filepath="$SCREENSHOT_DIR/screenshot_region_$(date +%Y%m%d_%H%M%S).png"
          grimblast copysave area "$filepath"

          # Restore the shader if it was active
          if [[ "$current_shader" != "None" ]]; then
            hyprshade on "$current_shader"
          fi

          send_notification "$filepath"
          ;;
        copy-path)
          copy_path
          ;;
        *)
          show_usage
          exit 1
          ;;
      esac
    '';
  };
}
