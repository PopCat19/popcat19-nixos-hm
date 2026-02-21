# screenshot.nix
#
# Purpose: Configure screenshot tools and wrapper script for Hyprland
#
# This module:
# - Installs screenshot tools (grimblast, gwenview, libnotify, jq)
# - Creates wrapper script with hyprshade integration
{ pkgs, ... }:
let
  screenshotScript = pkgs.writeShellScriptBin "screenshot" ''
    set -euo pipefail

    DEFAULT_DIR="$HOME/Pictures/Screenshots"
    XDG_SCREENSHOTS_DIR="''${XDG_SCREENSHOTS_DIR:-$DEFAULT_DIR}"
    mkdir -p "$XDG_SCREENSHOTS_DIR"

    MODE="output"
    KEEP_SHADER=false
    POSITIONAL_ARGS=()

    while [[ $# -gt 0 ]]; do
      case $1 in
        --keep-shader)
          KEEP_SHADER=true
          shift
          ;;
        --help|-h)
          echo "Usage: screenshot [monitor|region|window|both] [--keep-shader]"
          echo ""
          echo "Modes:"
          echo "  monitor - Screenshot current monitor (default)"
          echo "  region  - Screenshot selected region"
          echo "  window  - Screenshot active window"
          echo "  both    - Screenshot both monitor and region"
          echo ""
          echo "Options:"
          echo "  --keep-shader - Preserve hyprshade effects in screenshot"
          exit 0
          ;;
        -*)
          echo "Unknown option: $1" >&2
          exit 1
          ;;
        *)
          POSITIONAL_ARGS+=("$1")
          shift
          ;;
      esac
    done

    set -- "''${POSITIONAL_ARGS[@]+''${POSITIONAL_ARGS[@]}}"

    if [[ $# -gt 1 ]]; then
      echo "Error: expected at most one positional argument, got $#" >&2
      exit 1
    fi

    if [[ $# -eq 1 ]]; then
      case $1 in
        monitor|full)   MODE="output" ;;
        region|area)    MODE="area" ;;
        window|active)  MODE="active" ;;
        both)           MODE="both" ;;
        *)
          echo "Error: unknown mode '$1'" >&2
          echo "Run 'screenshot --help' for usage." >&2
          exit 1
          ;;
      esac
    fi

    # ── Hyprshade: save/restore once around the entire operation ──

    SAVED_SHADER=""

    save_hyprshade() {
      if [[ "$KEEP_SHADER" == "true" ]]; then
        return
      fi
      if ! command -v hyprshade >/dev/null 2>&1; then
        return
      fi
      SAVED_SHADER=$(hyprshade current 2>/dev/null || echo "")
      if [[ -n "$SAVED_SHADER" && "$SAVED_SHADER" != "Off" ]]; then
        hyprshade off >/dev/null 2>&1 || true
      else
        SAVED_SHADER=""
      fi
    }

    restore_hyprshade() {
      if [[ -n "$SAVED_SHADER" ]]; then
        hyprshade on "$SAVED_SHADER" >/dev/null 2>&1 || true
        SAVED_SHADER=""
      fi
    }

    cleanup() {
      restore_hyprshade
    }
    trap cleanup EXIT INT TERM HUP

    # ── Helpers ──

    slugify_app_name() {
      local s="''${1:-}"
      if [[ -z "$s" ]]; then
        echo "screen"
        return
      fi
      s="''${s,,}"
      s="''${s//[^a-z0-9._-]/-}"
      while [[ "$s" == *--* ]]; do
        s="''${s//--/-}"
      done
      s="''${s#-}"
      s="''${s%-}"
      echo "''${s:-screen}"
    }

    get_app_name() {
      local app="screen"
      if command -v hyprctl >/dev/null 2>&1; then
        local json
        json=$(hyprctl activewindow -j 2>/dev/null || true)
        if [[ -n "$json" ]]; then
          local cls
          cls=$(echo "$json" | ${pkgs.jq}/bin/jq -r '.class // empty' 2>/dev/null || true)
          if [[ -n "$cls" && "$cls" != "null" ]]; then
            app="$cls"
          fi
        fi
      fi
      slugify_app_name "$app"
    }

    next_filename() {
      local dir="$1"
      local app="$2"
      local suffix="''${3:-}"
      local date
      date=$(date +%Y%m%d)
      local prefix="''${app}_''${date}-"
      local n=1
      while [[ -e "$dir/''${prefix}''${n}''${suffix}.png" ]]; do
        ((n++))
      done
      echo "''${prefix}''${n}''${suffix}.png"
    }

    take_screenshot() {
      local mode="$1"
      local dir="$2"
      local filename="$3"
      local screenshot_path="$dir/$filename"

      # --freeze is only useful for area selection
      local -a grimblast_cmd=(
        ${pkgs.grimblast}/bin/grimblast
      )
      if [[ "$mode" == "area" ]]; then
        grimblast_cmd+=(--freeze)
      fi
      grimblast_cmd+=(copysave "$mode" "$screenshot_path")

      if "''${grimblast_cmd[@]}"; then
        if [[ -f "$screenshot_path" ]]; then
          ${pkgs.libnotify}/bin/notify-send \
            "Screenshot" \
            "$mode screenshot saved: $filename" \
            -i camera-photo \
            2>/dev/null || true
          echo "Saved: $screenshot_path"
          return 0
        fi
      fi

      # Clean up partial file on failure / cancellation
      rm -f "$screenshot_path"
      echo "Screenshot cancelled ($mode)" >&2
      return 1
    }

    # ── Main ──

    APP_NAME=$(get_app_name)

    save_hyprshade

    case "$MODE" in
      output|area|active)
        FILENAME=$(next_filename "$XDG_SCREENSHOTS_DIR" "$APP_NAME")
        take_screenshot "$MODE" "$XDG_SCREENSHOTS_DIR" "$FILENAME"
        ;;
      both)
        FILENAME_OUTPUT=$(next_filename "$XDG_SCREENSHOTS_DIR" "$APP_NAME" "_output")
        take_screenshot "output" "$XDG_SCREENSHOTS_DIR" "$FILENAME_OUTPUT"

        FILENAME_AREA=$(next_filename "$XDG_SCREENSHOTS_DIR" "$APP_NAME" "_area")
        take_screenshot "area" "$XDG_SCREENSHOTS_DIR" "$FILENAME_AREA"
        ;;
    esac

    # restore_hyprshade runs automatically via the EXIT trap
  '';
in
{
  home.file."Pictures/Screenshots/.keep".text = "";

  home.packages = with pkgs; [
    grimblast
    jq
    kdePackages.gwenview
    libnotify
    screenshotScript
  ];
}
