# screenshot.nix
#
# Purpose: Provide hyprshot wrapper with shader suspend/restore around capture
#
# This module:
# - Installs hyprshot
# - Creates screenshot wrapper handling shader state and capture mode
{ pkgs, ... }:
let
  screenshotScript = pkgs.writeShellScriptBin "screenshot" ''
    set -euo pipefail

    SCREENSHOTS_DIR="''${XDG_SCREENSHOTS_DIR:-$HOME/Pictures/Screenshots}"
    mkdir -p "$SCREENSHOTS_DIR"

    MODE=""
    KEEP_SHADER=false

    for arg in "$@"; do
      case "$arg" in
        monitor)       MODE="output" ;;
        region)        MODE="region" ;;
        window)        MODE="window" ;;
        --keep-shader) KEEP_SHADER=true ;;
        *)
          echo "Usage: screenshot [monitor|region|window] [--keep-shader]" >&2
          exit 1
          ;;
      esac
    done

    : "''${MODE:=output}"

    ACTIVE_SHADER=""
    if ! $KEEP_SHADER && command -v hyprshade >/dev/null 2>&1; then
      ACTIVE_SHADER=$(hyprshade current 2>/dev/null || true)
      if [[ -n "$ACTIVE_SHADER" && "$ACTIVE_SHADER" != "off" ]]; then
        hyprshade off
        # hyprshade off is async; without delay hyprshot freezes before shader clears
        sleep 0.1
      else
        ACTIVE_SHADER=""
      fi
    fi

    ${pkgs.hyprshot}/bin/hyprshot \
      --freeze \
      --mode "$MODE" \
      -o "$SCREENSHOTS_DIR"

    # Restore after hyprshot exits — not via trap, which fires on hyprshot errors
    # and causes double-restore stacking
    if [[ -n "$ACTIVE_SHADER" ]]; then
      hyprshade on "$ACTIVE_SHADER"
    fi
  '';
in
{
  home.file."Pictures/Screenshots/.keep".text = "";

  home.packages = with pkgs; [
    hyprshot
    screenshotScript
  ];
}
