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

  # Main screenshot dispatcher
  home.file.".local/bin/screenshot" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      case "$1" in
        full|screen)
          exec ~/.local/bin/screenshot-full
          ;;
        region|area)
          exec ~/.local/bin/screenshot-region
          ;;
        *)
          echo "Usage: $0 {full|region}"
          echo "  full   - Take fullscreen screenshot"
          echo "  region - Take region screenshot"
          exit 1
          ;;
      esac
    '';
  };

  # Full screen screenshot script
  home.file.".local/bin/screenshot-full" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # Create screenshots directory if it doesn't exist
      mkdir -p ~/Pictures/Screenshots

      # Generate filename with timestamp
      filename="screenshot_$(date +%Y%m%d_%H%M%S).png"
      filepath="$HOME/Pictures/Screenshots/$filename"

      # Take screenshot using grimblast
      # --notify: show notification
      # copysave: copy to clipboard AND save to file
      # screen: capture all outputs
      grimblast --notify copysave screen "$filepath"
    '';
  };

  # Region screenshot script
  home.file.".local/bin/screenshot-region" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # Create screenshots directory if it doesn't exist
      mkdir -p ~/Pictures/Screenshots

      # Generate filename with timestamp
      filename="screenshot_region_$(date +%Y%m%d_%H%M%S).png"
      filepath="$HOME/Pictures/Screenshots/$filename"

      # Take region screenshot using grimblast
      # --notify: show notification
      # copysave: copy to clipboard AND save to file
      # area: select region with mouse
      grimblast --notify copysave area "$filepath"
    '';
  };
}
