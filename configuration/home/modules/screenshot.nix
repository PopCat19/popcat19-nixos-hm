# screenshot.nix
#
# Purpose: Screenshot capture with optional shader bypass
#
# This module:
# - Installs hyprshot for Wayland screenshot capture
# - Creates wrapper that optionally bypasses hyprshade without altering state

{ pkgs, ... }:

# Hyprland binds:
#
#   "$mainMod, P, exec, screenshot output"
#   "$mainMod+Ctrl, P, exec, screenshot region"
#   "$mainMod+Shift, P, exec, screenshot output --no-shader"
#   "$mainMod+Shift+Ctrl, P, exec, screenshot region --no-shader"
#
# --no-shader: captures without shader, restores prior state afterward
# region: always disables shader before freeze to prevent double-application

let
  screenshotScript = pkgs.writeShellScriptBin "screenshot" ''
    set -euo pipefail

    log() { echo "[screenshot] $(date +%H:%M:%S) $*" >> /tmp/screenshot.log; }

    mode="output"
    no_shader=false

    while [[ $# -gt 0 ]]; do
      case "$1" in
        output|region) mode="$1" ;;
        --no-shader) no_shader=true ;;
        *) echo "Usage: screenshot [output|region] [--no-shader]" >&2; exit 1 ;;
      esac
      shift
    done

    log "invoked: mode=$mode no_shader=$no_shader"

    # region always disables shader: --freeze bakes the compositor frame,
    # leaving the shader active would apply it twice in the captured output
    needs_shader_off=false
    [[ "$mode" == "region" ]] && needs_shader_off=true
    [[ "$no_shader" == "true" ]] && needs_shader_off=true

    initial_shader=""
    if [[ "$needs_shader_off" == "true" ]] && command -v hyprshade >/dev/null 2>&1; then
      current=$(hyprshade current 2>/dev/null || true)
      [[ "$current" == "off" ]] && current=""
      log "pre-capture: shader='${"current:-none"}'"
      if [[ -n "$current" ]]; then
        initial_shader="$current"
        hyprshade off
        log "shader disabled: reason=$(
          [[ "$mode" == "region" ]] && echo "freeze-double-stack" || echo "no-shader-flag"
        )"
      else
        log "no active shader, skipping disable"
      fi
    else
      log "shader state untouched: mode=$mode no_shader=$no_shader"
    fi

    # --freeze only for region (interactive selection); output is non-interactive
    freeze=""
    [[ "$mode" == "region" ]] && freeze="--freeze"

    log "starting hyprshot: mode=$mode freeze=${"freeze:+true"}"
    hyprshot --mode "$mode" --output-folder "$HOME/Pictures/Screenshots" --clipboard $freeze
    log "hyprshot done"

    if [[ -n "$initial_shader" ]]; then
      sleep 0.3
      log "restoring shader: $initial_shader"
      hyprshade off 2>/dev/null || true
      hyprshade on "$initial_shader"
      sleep 0.3
      after=$(hyprshade current 2>/dev/null || true)
      log "restore complete: current='${"after:-none"}'"
    fi

    log "done"
  '';
in
{
  home.file."Pictures/Screenshots/.keep".text = "";

  home.packages = with pkgs; [
    hyprshot
    screenshotScript
  ];
}
