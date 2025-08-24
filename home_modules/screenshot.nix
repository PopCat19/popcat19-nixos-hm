{ config, pkgs, ... }:

{
  # Screenshot configuration for Hyprland using grimblast

  home.packages = with pkgs; [
    # Core screenshot tools
    hyprshot                           # Primary screenshot tool for Hyprland
    kdePackages.gwenview               # Image viewer
    libnotify                          # Desktop notifications (notify-send)
    jq                                 # For parsing hyprctl JSON (app name)
  ];

  # Create Screenshots directory
  home.file."Pictures/Screenshots/.keep".text = "";

  # Screenshot wrapper script for hyprshot with hyprshade integration
  home.file.".local/bin/screenshot" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # Screenshot wrapper using hyprshot with hyprshade integration
      # Usage: screenshot [monitor|region]
      #
      # Behavior:
      # - Uses hyprshot with --freeze for clean capture
      # - Always saves to ~/Pictures/Screenshots AND copies to clipboard
      # - Filename: appname_yyyymmdd-count.png (count increments per day/app)
      # - Temporarily disables hyprshade around the capture, then restores it

      set -euo pipefail

      MODE="''${1:-monitor}"
      SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
      XDG_SCREENSHOTS_DIR="''${XDG_SCREENSHOTS_DIR:-$SCREENSHOT_DIR}"

      # Ensure screenshot directory exists
      mkdir -p "$XDG_SCREENSHOTS_DIR"

      # Determine active app name (class) and sanitize to lowercase alnum-plus
      get_app_name() {
        local app="screen"
        if command -v hyprctl >/dev/null 2>&1; then
          local cls
          cls="$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty' || true)"
          if [[ -n "''${cls:-}" ]]; then
            app="$cls"
          fi
        fi
        app="$(echo "$app" | tr '[:upper:]' '[:lower:]')"
        # keep only [a-z0-9-_], convert spaces to dashes
        app="${app// /-}"
        app="$(echo "$app" | sed -E 's/[^a-z0-9._-]+/-/g' | sed -E 's/-+/-/g' | sed -E 's/^-+|-+$//g')"
        echo "''${app:-screen}"
      }

      # Generate next filename with incremental count: app_YYYYMMDD-N.png
      next_filename() {
        local app="$1"
        local date="$(date +%Y%m%d)"
        local prefix="${app}_${date}-"
        local max=0
        shopt -s nullglob
        for f in "$XDG_SCREENSHOTS_DIR"/"$prefix"*".png"; do
          # extract numeric suffix before .png
          local base="$(basename "$f")"
          if [[ "$base" =~ ^${app}_${date}-([0-9]+)\.png$ ]]; then
            local n="''${BASH_REMATCH[1]}"
            if (( n > max )); then max=$n; fi
          fi
        done
        shopt -u nullglob
        local next=$((max + 1))
        echo "${app}_${date}-${next}.png"
      }

      # Toggle hyprshade off during capture, then restore
      run_with_hyprshade_workaround() {
        local cmd_pid shader
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

      APP_NAME="$(get_app_name)"
      FILENAME="$(next_filename "$APP_NAME")"

      case "$MODE" in
        "monitor"|"full")
          # Save and copy: default hyprshot behavior (no --clipboard-only)
          run_with_hyprshade_workaround hyprshot --freeze --silent -m output -o "$XDG_SCREENSHOTS_DIR" -f "$FILENAME"
          notify-send "Screenshot" "Monitor screenshot saved and copied: $FILENAME" -i camera-photo || true
          echo "Saved and copied: $XDG_SCREENSHOTS_DIR/$FILENAME"
          ;;
        "region"|"area")
          run_with_hyprshade_workaround hyprshot --freeze --silent -m region -o "$XDG_SCREENSHOTS_DIR" -f "$FILENAME"
          notify-send "Screenshot" "Region screenshot saved and copied: $FILENAME" -i camera-photo || true
          echo "Saved and copied: $XDG_SCREENSHOTS_DIR/$FILENAME"
          ;;
        *)
          echo "Usage: screenshot [monitor|region]"
          echo ""
          echo "Modes:"
          echo "  monitor - Screenshot current monitor (default)"
          echo "  region  - Screenshot selected region"
          exit 1
          ;;
      esac
    '';
  };
}