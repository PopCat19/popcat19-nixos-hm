{ config, pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════════════════════════
  # 📸 SCREENSHOT SYSTEM CONFIGURATION
  # ═══════════════════════════════════════════════════════════════════════════════
  #
  # Unified screenshot system that handles both full-screen and region screenshots
  # with optional hyprshade integration and still-image frame for region selection.
  #
  # FEATURES:
  # • Unified script for both full and region screenshots
  # • Still-image frame for region selection (freezes screen during selection)
  # • Optional hyprshade integration (gracefully handles missing hyprshade)
  # • Automatic clipboard integration
  # • Desktop notifications
  # • Monitor-aware screenshot capture
  # • Organized screenshot directory structure
  #
  # USAGE:
  # screenshot full    - Take full screenshot of current monitor
  # screenshot region  - Take region screenshot with still-image frame
  # ═══════════════════════════════════════════════════════════════════════════════

  home.packages = with pkgs; [
    # ─── CORE SCREENSHOT TOOLS ───
    grim                               # Wayland screenshot utility (primary capture tool)
    slurp                              # Region selection for screenshots with visual feedback
    wl-clipboard                       # Wayland clipboard utilities (for automatic copy)
    grimblast                          # Hyprland screenshot utility with freeze support

    # ─── SCREENSHOT ENHANCEMENT TOOLS ───
    swappy                             # Screenshot annotation tool (optional editing)
    satty                              # Alternative screenshot annotation tool
    hyprpicker                         # Color picker for Hyprland (complementary tool)

    # ─── SYSTEM INTEGRATION DEPENDENCIES ───
    jq                                 # JSON processor (used for monitor detection)
    libnotify                          # Desktop notifications (screenshot confirmations)

    # Note: hyprshade intentionally excluded - script handles optional integration

    # ─── SCREENSHOT DIAGNOSTIC TOOL ───
    (pkgs.writeShellScriptBin "check-screenshot-system" ''
      #!/usr/bin/env bash

      # ═══════════════════════════════════════════════════════════════════════════════
      # 📸 SCREENSHOT SYSTEM DIAGNOSTIC TOOL
      # ═══════════════════════════════════════════════════════════════════════════════

      echo "🔍 Screenshot System Diagnostics"
      echo "════════════════════════════════════════════════════════════════════════════"

      # Check core tools
      echo "📋 Core Tools:"
      for tool in grim slurp wl-copy jq notify-send; do
          if command -v "$tool" >/dev/null 2>&1; then
              echo "  ✅ $tool: $(command -v "$tool")"
          else
              echo "  ❌ $tool: NOT FOUND"
          fi
      done

      # Check optional tools
      echo ""
      echo "🔧 Optional Tools:"
      for tool in hyprshade hyprctl; do
          if command -v "$tool" >/dev/null 2>&1; then
              echo "  ✅ $tool: $(command -v "$tool")"
          else
              echo "  ⚠️  $tool: NOT FOUND (optional)"
          fi
      done

      # Check screenshot directory
      echo ""
      echo "📁 Directory Structure:"
      screenshot_dir="$HOME/Pictures/Screenshots"
    flameshot
      if [[ -d "$screenshot_dir" ]]; then
          echo "  ✅ Screenshot directory: $screenshot_dir"
          echo "  📊 Screenshot count: $(find "$screenshot_dir" -name "*.png" 2>/dev/null | wc -l)"
      else
          echo "  ❌ Screenshot directory: NOT FOUND"
      fi

      # Check scripts
      echo ""
      echo "📜 Screenshot Scripts:"
      for script in screenshot screenshot-full screenshot-region; do
          script_path="$HOME/.local/bin/$script"
          if [[ -x "$script_path" ]]; then
              echo "  ✅ $script: $script_path"
          else
              echo "  ❌ $script: NOT FOUND OR NOT EXECUTABLE"
          fi
      done

      # Test basic functionality
      echo ""
      echo "🧪 Basic Functionality Test:"
      if command -v grim >/dev/null 2>&1 && command -v slurp >/dev/null 2>&1; then
          echo "  ✅ Screenshot system ready"
          echo "  💡 Usage: screenshot [full|region|test-hyprshade]"
      else
          echo "  ❌ Screenshot system not ready - missing core tools"
      fi

      # Test hyprshade restoration functionality
      echo ""
      echo "🧪 Hyprshade Restoration Test:"
      if command -v hyprshade >/dev/null 2>&1; then
          echo "  ✅ hyprshade available - restoration test available"
          echo "  💡 Run: screenshot test-hyprshade"
      else
          echo "  ⚠️  hyprshade not available - restoration not needed"
      fi

      echo ""
      echo "════════════════════════════════════════════════════════════════════════════"
    '')
  ];

  # ─── SCREENSHOT DIRECTORY STRUCTURE ───
  # Ensure screenshot directories exist with proper structure
  home.file."Pictures/Screenshots/.keep".text = "";

  # ─── UNIFIED SCREENSHOT SCRIPT ───
  home.file.".local/bin/screenshot" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # ═══════════════════════════════════════════════════════════════════════════════
      # 📸 UNIFIED SCREENSHOT SYSTEM
      # ═══════════════════════════════════════════════════════════════════════════════
      #
      # Enhanced screenshot system with still-image frame for region selection
      # and optional hyprshade integration.
      #
      # USAGE:
      #   screenshot full    - Full screenshot of current monitor
      #   screenshot region  - Region screenshot with still-image frame
      #
      # FEATURES:
      # • Still-image frame: Freezes screen during region selection
      # • Optional hyprshade: Works with or without hyprshade installed
      # • Monitor-aware: Detects and targets current monitor
      # • Clipboard integration: Automatically copies to clipboard
      # • Notifications: Desktop notifications for user feedback
      # • Proper cleanup: Removes temporary files and restores state
      #
      # REGION SELECTION CONTROLS:
      # • ESC key: Cancel region selection and exit
      # • Mouse click: Cancel selection (behavior depends on slurp implementation)
      # • Hold and drag: Select region
      # • Space + drag: Move existing selection instead of resizing
      # ═══════════════════════════════════════════════════════════════════════════════

      set -euo pipefail

      # ─── CONFIGURATION ───
      SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
      TEMP_DIR="/tmp/screenshot-$$"
      TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
      GLOBAL_SAVED_SHADER=""  # Global variable for hyprshade state

      # ─── UTILITY FUNCTIONS ───

      # Function to check if hyprshade is available and enabled
      has_hyprshade() {
          command -v hyprshade >/dev/null 2>&1
      }

      # Function to get current monitor
      get_current_monitor() {
          if command -v hyprctl &> /dev/null; then
              hyprctl monitors -j | jq -r '.[] | select(.focused) | .name' 2>/dev/null || echo ""
          else
              echo ""
          fi
      }

      # Function to get current hyprshade state
      get_hyprshade_state() {
          if has_hyprshade; then
              hyprshade current 2>/dev/null || echo ""
          else
              echo ""
          fi
      }

      # Function to manage hyprshade
      manage_hyprshade() {
          local action="$1"
          local shader_name="''${2:-}"

          if ! has_hyprshade; then
              return 0
          fi

          case "$action" in
              "off")
                  hyprshade off 2>/dev/null || true
                  ;;
              "restore")
                  if [[ -n "$shader_name" ]]; then
                      hyprshade on "$shader_name" 2>/dev/null || true
                  fi
                  ;;
          esac
      }

      # Function to send notification with optional action
      notify_user() {
          local title="$1"
          local message="$2"
          local icon="''${3:-}"
          local filepath="''${4:-}"

          if command -v notify-send &> /dev/null; then
              if [[ -n "$filepath" ]] && [[ -f "$filepath" ]]; then
                  # Enhanced notification with action to copy full path
                  if [[ -n "$icon" ]] && [[ -f "$icon" ]]; then
                      notify-send "$title" "$message" -i "$icon" \
                          --action="copy_path=Copy Path" \
                          --action="open_folder=Open Folder" | while read action; do
                          case "$action" in
                              "copy_path")
                                  echo "$filepath" | wl-copy
                                  notify-send "Path Copied" "Full path copied to clipboard"
                                  ;;
                              "open_folder")
                                  xdg-open "$(dirname "$filepath")"
                                  ;;
                          esac
                      done &
                  else
                      notify-send "$title" "$message" \
                          --action="copy_path=Copy Path" \
                          --action="open_folder=Open Folder" | while read action; do
                          case "$action" in
                              "copy_path")
                                  echo "$filepath" | wl-copy
                                  notify-send "Path Copied" "Full path copied to clipboard"
                                  ;;
                              "open_folder")
                                  xdg-open "$(dirname "$filepath")"
                                  ;;
                          esac
                      done &
                  fi
              else
                  # Fallback for notifications without file path actions
                  if [[ -n "$icon" ]] && [[ -f "$icon" ]]; then
                      notify-send "$title" "$message" -i "$icon"
                  else
                      notify-send "$title" "$message"
                  fi
              fi
          fi
      }

      # Function to copy to clipboard
      copy_to_clipboard() {
          local filepath="$1"

          if command -v wl-copy &> /dev/null && [[ -f "$filepath" ]]; then
              wl-copy < "$filepath"
              echo "Screenshot copied to clipboard"
              return 0
          else
              echo "Warning: wl-copy not found or file doesn't exist - screenshot not copied to clipboard"
              return 1
          fi
      }

      # Function to cleanup temporary files
      cleanup() {
          if [[ -d "$TEMP_DIR" ]]; then
              rm -rf "$TEMP_DIR"
          fi

          # Restore hyprshade if it was disabled
          if [[ -n "''${SAVED_SHADER:-}" ]]; then
              manage_hyprshade "restore" "$SAVED_SHADER"
          fi
      }

      # Function to take full screenshot
      take_full_screenshot() {
          local filename="screenshot_full_''${TIMESTAMP}.png"
          local filepath="''${SCREENSHOT_DIR}/''${filename}"

          echo "Taking full screenshot..."

          # Get current monitor
          local current_monitor
          current_monitor=$(get_current_monitor)

          # Take screenshot
          if [[ -n "$current_monitor" ]]; then
              grim -o "$current_monitor" "$filepath"
              echo "Screenshot of monitor '$current_monitor' saved to: $filepath"
          else
              grim "$filepath"
              echo "Screenshot saved to: $filepath"
          fi

          # Copy to clipboard and notify
          copy_to_clipboard "$filepath"
          notify_user "Screenshot" "Full screenshot saved to Pictures/Screenshots" "$filepath" "$filepath"

          return 0
      }

      # Function to take region screenshot with grimblast freeze
      take_region_screenshot_with_freeze() {
          local filename="screenshot_region_''${TIMESTAMP}.png"
          local filepath="''${SCREENSHOT_DIR}/''${filename}"

          echo "Taking region screenshot with still-image frame..."
          echo "🎯 Region Selection Active:"
          echo "   • Drag to select area"
          echo "   • ESC to cancel"
          echo "   • Click to cancel"
          echo "   • Space + drag to move selection"

          # Use grimblast with freeze for still-image frame effect
          if command -v grimblast &> /dev/null; then
              if grimblast --freeze save area "$filepath" 2>/dev/null; then
                  echo "Region screenshot saved to: $filepath"

                  # Copy to clipboard and notify with actions
                  copy_to_clipboard "$filepath"
                  notify_user "Screenshot" "Region screenshot saved to Pictures/Screenshots" "$filepath" "$filepath"

                  return 0
              else
                  echo "Screenshot cancelled - no region selected"
                  # Restore hyprshade on cancellation
                  if [[ -n "$GLOBAL_SAVED_SHADER" ]]; then
                      manage_hyprshade "restore" "$GLOBAL_SAVED_SHADER"
                  fi
                  return 1
              fi
          else
              echo "Warning: grimblast not found, falling back to grim+slurp without freeze"
              return 2
          fi
      }

      # Function to take region screenshot with fallback method
      take_region_screenshot_fallback() {
          local filename="screenshot_region_''${TIMESTAMP}.png"
          local filepath="''${SCREENSHOT_DIR}/''${filename}"

          echo "Taking region screenshot (fallback mode)..."

          # Get current monitor for slurp constraint
          local current_monitor
          current_monitor=$(get_current_monitor)

          # Use slurp to select region (no trap to avoid ESC interference)
          echo "🎯 Region Selection Active:"
          echo "   • Drag to select area"
          echo "   • ESC to cancel"
          echo "   • Click to cancel"
          echo "   • Space + drag to move selection"

          local region
          if [[ -n "$current_monitor" ]]; then
              # Try with monitor constraint first, fallback to unconstrained
              region=$(slurp -o "$current_monitor" 2>/dev/null || slurp 2>/dev/null || echo "")
          else
              region=$(slurp 2>/dev/null || echo "")
          fi

          if [[ -n "$region" ]]; then
              # Take screenshot of selected region
              grim -g "$region" "$filepath"
              echo "Region screenshot saved to: $filepath"

              # Copy to clipboard and notify with actions
              copy_to_clipboard "$filepath"
              notify_user "Screenshot" "Region screenshot saved to Pictures/Screenshots" "$filepath" "$filepath"

              return 0
          else
              echo "Screenshot cancelled - no region selected"
              return 1
          fi
      }

      # Function to take region screenshot with still-image frame
      take_region_screenshot() {
          # Save current hyprshade state globally
          GLOBAL_SAVED_SHADER=$(get_hyprshade_state)
          echo "Saved hyprshade state: '$GLOBAL_SAVED_SHADER'"

          # Disable hyprshade for cleaner selection
          manage_hyprshade "off"

          # Small delay to ensure hyprshade is fully disabled
          sleep 0.1

          # Try grimblast first for freeze functionality
          if take_region_screenshot_with_freeze; then
              # Restore hyprshade
              if [[ -n "$GLOBAL_SAVED_SHADER" ]]; then
                  echo "Restoring hyprshade state: '$GLOBAL_SAVED_SHADER'"
                  manage_hyprshade "restore" "$GLOBAL_SAVED_SHADER"
              fi
              return 0
          elif [[ $? -eq 2 ]]; then
              # Grimblast not available, use fallback
              if take_region_screenshot_fallback; then
                  # Restore hyprshade
                  if [[ -n "$GLOBAL_SAVED_SHADER" ]]; then
                      echo "Restoring hyprshade state: '$GLOBAL_SAVED_SHADER'"
                      manage_hyprshade "restore" "$GLOBAL_SAVED_SHADER"
                  fi
                  return 0
              else
                  # Restore hyprshade on failure
                  if [[ -n "$GLOBAL_SAVED_SHADER" ]]; then
                      echo "Restoring hyprshade state: '$GLOBAL_SAVED_SHADER'"
                      manage_hyprshade "restore" "$GLOBAL_SAVED_SHADER"
                  fi
                  return 1
              fi
          else
              # Grimblast failed (user cancelled) - hyprshade already restored in function
              return 1
          fi
      }

      # Function to test hyprshade restoration
      test_hyprshade_restoration() {
          echo "🧪 Testing hyprshade restoration..."

          # Check if hyprshade is available
          if ! command -v hyprshade &> /dev/null; then
              echo "⚠️  hyprshade not found - skipping restoration test"
              return 0
          fi

          # Get initial state
          local initial_state
          initial_state=$(get_hyprshade_state)
          echo "Initial hyprshade state: '$initial_state'"

          # Simulate the screenshot workflow
          echo "Simulating region screenshot workflow..."

          # Save state (like in region screenshot)
          GLOBAL_SAVED_SHADER="$initial_state"

          # Turn off hyprshade
          echo "Disabling hyprshade..."
          manage_hyprshade "off"
          sleep 0.5

          local current_state
          current_state=$(get_hyprshade_state)
          echo "State after disable: '$current_state'"

          # Restore hyprshade
          echo "Restoring hyprshade..."
          if [[ -n "$GLOBAL_SAVED_SHADER" ]]; then
              manage_hyprshade "restore" "$GLOBAL_SAVED_SHADER"
          fi
          sleep 0.5

          local final_state
          final_state=$(get_hyprshade_state)
          echo "Final hyprshade state: '$final_state'"

          # Verify restoration
          if [[ "$initial_state" == "$final_state" ]]; then
              echo "✅ Hyprshade restoration test PASSED"
              return 0
          else
              echo "❌ Hyprshade restoration test FAILED"
              echo "   Expected: '$initial_state'"
              echo "   Got: '$final_state'"
              return 1
          fi
      }

      # ─── MAIN SCRIPT LOGIC ───

      # Note: No trap set to avoid interfering with slurp's ESC handling

      # Ensure screenshot directory exists
      mkdir -p "$SCREENSHOT_DIR"

      # Validate required tools
      if ! command -v grim &> /dev/null; then
          echo "Error: grim not found. Please install grim for Wayland screenshots."
          exit 1
      fi

      # Parse command line arguments
      case "''${1:-}" in
          "full")
              take_full_screenshot
              ;;
          "region")
              if ! command -v slurp &> /dev/null; then
                  echo "Error: slurp not found. Please install slurp for region selection."
                  exit 1
              fi
              take_region_screenshot
              ;;
          "test-hyprshade")
              test_hyprshade_restoration
              ;;
          *)
              echo "Usage: screenshot [full|region|test-hyprshade]"
              echo ""
              echo "Commands:"
              echo "  full    - Take full screenshot of current monitor"
              echo "  region  - Take region screenshot with still-image frame"
              echo "  test-hyprshade - Test hyprshade restoration functionality"
              echo ""
              echo "Features:"
              echo "  • Automatic clipboard copy"
              echo "  • Desktop notifications"
              echo "  • Optional hyprshade integration"
              echo "  • Monitor-aware capture"
              echo "  • Still-image frame for region selection (grimblast)"
              echo ""
              echo "Region Selection Controls:"
              echo "  • ESC key - Cancel selection and exit"
              echo "  • Mouse click - Cancel selection"
              echo "  • Drag - Select area"
              echo "  • Space + drag - Move selection"
              echo ""
              echo "Testing Commands:"
              echo "  screenshot test-hyprshade - Test hyprshade restoration"
              exit 1
              ;;
      esac

      # Manual cleanup since no trap is set
      if [[ -d "$TEMP_DIR" ]]; then
          rm -rf "$TEMP_DIR"
      fi
    '';
  };

  # ─── LEGACY COMPATIBILITY ───
  # Create symlinks for backward compatibility with existing keybindings
  home.file.".local/bin/screenshot-full" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Legacy compatibility wrapper
      exec screenshot full "$@"
    '';
  };

  home.file.".local/bin/screenshot-region" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Legacy compatibility wrapper
      exec screenshot region "$@"
    '';
  };


}
