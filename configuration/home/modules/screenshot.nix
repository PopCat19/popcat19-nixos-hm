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

    if [[ $# -gt 0 && "${"1:-"}" == "--keep-shader" ]]; then
      KEEP_SHADER=true
    fi

    if [[ $# -eq 1 ]]; then
      case $1 in
        monitor|"")    MODE="output" ;;
        region)        MODE="area" ;;
        window)        MODE="active" ;;
        both)          MODE="both" ;;
        *)
          echo "Error: unknown mode '$1'" >&2
          exit 1
          ;;
      esac
    fi

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
    trap restore_hyprshade EXIT INT TERM HUP

    slugify_app_name() {
      tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9._-' '-'
    }

    get_app_name() {
      if command -v hyprctl >/dev/null 2>&1; then
        hyprctl activewindow -j 2>/dev/null \
          | ${pkgs.jq}/bin/jq -r '.class // "screen"' 2>/dev/null \
          | slugify_app_name
      else
        echo "screen"
      fi
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

      local -a grimblast_cmd=(
        ${pkgs.grimblast}/bin/grimblast
      )
      if [[ "$mode" == "area" ]]; then
        grimblast_cmd+=(--freeze)
      fi
      grimblast_cmd+=(copysave "$mode" "$screenshot_path")

      if "''${grimblast_cmd[@]}"; then
        if [[ -f "$screenshot_path" ]]; then
          ${pkgs.libnotify}/bin/notify-send "Screenshot" "$filename saved" -i camera-photo 2>/dev/null || true
          echo "Saved: $screenshot_path"
          return 0
        fi
      fi

      rm -f "$screenshot_path"
      echo "Screenshot cancelled ($mode)" >&2
      return 1
    }

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
